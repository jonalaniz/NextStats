//
//  NetworkController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz.

import UIKit

class NetworkController {
    static let baseConfig: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default

        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.httpMaximumConnectionsPerHost = 1

        return config
    }()

    /// Returns the singleton `NetworkController` instance
    public static let shared = NetworkController()

    private init() { }

    func fetchAuthenticationData(url: URL) async throws -> AuthenticationObject {
        let urlWithEndpoint = try buildEndpointURL(baseURL: url, endpoint: .login)

        var request  = URLRequest(url: urlWithEndpoint)
        request.httpMethod = "POST"
        request.setUserAgent()

        let config = config()
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        guard let object = try? JSONDecoder().decode(AuthenticationObject.self,
                                                     from: data) else {
            throw NetworkError.invalidData
        }

        return object
    }

    func fetchServerStatisticsData(url: URL, authentication: String) async throws -> ServerStats {
        let urlWithEndpoint = try buildEndpointURL(baseURL: url, endpoint: .info)

        var request = URLRequest(url: urlWithEndpoint)
        request.setUserAgent()

        let config = config(authString: authentication)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        guard let object = try? JSONDecoder().decode(ServerStats.self,
                                                     from: data) else {
            throw NetworkError.invalidData
        }

        return object
    }

    /// Generic fetch request that takes only a URL.
    func fetchData(from url: URL) async throws -> Data {
        let session = URLSession(configuration: config())
        let request = URLRequest(url: url)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        return data
    }

    func fetchData(with request: URLRequest,
                   config: URLSessionConfiguration = NetworkController.baseConfig) async throws -> Data {
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        return data
    }

    func fetchUsers(url: URL, authentication: String) async throws -> Users {
        let urlWithEndpoint = try buildEndpointURL(baseURL: url, endpoint: .users)

        var request = URLRequest(url: urlWithEndpoint)
        request.setUserAgent()

        let config = config(authString: authentication, ocsApiRequest: true)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        guard let users = try? XMLDecoder().decode(Users.self, from: data)
        else {
            throw NetworkError.invalidData
        }

        return users
    }

    func neoPost(url: URL,
                 authentication: String? = nil) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setUserAgent()
        request.addValue(Header.contentType.value(),
                         forHTTPHeaderField: Header.contentType.key())

        let configuration: URLSessionConfiguration
        if authentication != nil {
            configuration = config(authString: authentication, ocsApiRequest: true)
        } else {
            configuration = URLSessionConfiguration.default
        }

        let session = URLSession(configuration: configuration)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        return data
    }

    func post(user data: Data, url: URL, authenticaiton: String) async throws -> Response {
        let urlWithEndpoint = try buildEndpointURL(baseURL: url, endpoint: .users)

        var request = URLRequest(url: urlWithEndpoint)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setUserAgent()
        request.addValue(Header.contentType.value(),
                         forHTTPHeaderField: Header.contentType.key())

        let config = config(authString: authenticaiton, ocsApiRequest: true)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        guard let response = try? XMLDecoder().decode(Response.self, from: data)
        else {
            throw NetworkError.invalidData
        }

        return response
    }

    func toggleUser(_ user: String,
                    at url: URL,
                    with authString: String) async throws -> Response {
        let urlWithEndpoint = URL(string: Endpoint.user.rawValue + user,
                                  relativeTo: url)!

        var request = URLRequest(url: urlWithEndpoint)
        request.httpMethod = "PUT"
        request.setUserAgent()

        let config = config(authString: authString, ocsApiRequest: true)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        guard let response = try? XMLDecoder().decode(Response.self, from: data)
        else {
            throw NetworkError.invalidData
        }

        return response
    }

    func deleteUser(_ user: String,
                    at url: URL,
                    with authString: String) async throws -> Response {
        let urlWithEndpoint = URL(string: Endpoint.user.rawValue + user,
                                  relativeTo: url)!

        var request = URLRequest(url: urlWithEndpoint)
        request.httpMethod = "DELETE"
        request.setUserAgent()

        let config = config(authString: authString, ocsApiRequest: true)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        guard let response = try? XMLDecoder().decode(Response.self, from: data)
        else {
            throw NetworkError.invalidData
        }

        return response
    }

    func deauthorize(at url: URL, config: URLSessionConfiguration) async throws -> Data {
        let session = URLSession(configuration: config)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (data, response) = try await session.data(for: request)

        _ = try validateResponse(response)

        return data
    }

    // MARK: - Helper Methods

    func request(url: URL,
                 with endpoint: Endpoint,
                 appending user: String? = nil) -> URLRequest {
        guard let user = user else {
            return URLRequest(url: URL(string: endpoint.rawValue,
                                       relativeTo: url)!)
        }

        return URLRequest(url: URL(string: endpoint.rawValue + user,
                                   relativeTo: url)!)
    }

    func config(authString: String? = nil,
                ocsApiRequest: Bool = false) -> URLSessionConfiguration {
        let configuration = NetworkController.baseConfig

        guard let authorizationString = authString else {
            return configuration
        }

        var headers = [Header.authorization.key(): authorizationString]

        if ocsApiRequest == true {
            // OCS-APIRequest is needed for legacy (XML based) requests
            headers.updateValue(Header.ocsAPIRequest.value(),
                                forKey: Header.ocsAPIRequest.key())
        } else {
            headers.updateValue(Header.acceptJSON.value(),
                                forKey: Header.acceptJSON.key())
        }

        configuration.httpAdditionalHeaders = headers

        return configuration
    }

    private func buildEndpointURL(baseURL: URL, endpoint: Endpoint) throws -> URL {
        guard let endpointURL = endpoint.url(relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }

        return endpointURL
    }

    private func validateResponse(_ response: URLResponse?) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.missingResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.unexpectedResponse(httpResponse)
        }
        return httpResponse
    }
}
