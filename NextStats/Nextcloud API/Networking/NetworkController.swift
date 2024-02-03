//
//  NetworkController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

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
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path += Endpoints.loginEndpoint.rawValue

        var request  = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setUserAgent()

        let config = config()
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw FetchError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw FetchError.unexpectedResponse(urlResponse)
        }

        guard let object = try? JSONDecoder().decode(AuthenticationObject.self,
                                                     from: data) else {
            throw FetchError.invalidData
        }

        return object
    }

    func fetchServerStatisticsData(url: URL, authentication: String) async throws -> ServerStats {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.clearQueryAndAppend(endpoint: .statEndpoint)

        var request = URLRequest(url: components.url!)
        request.setUserAgent()

        let config = config(authString: authentication)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw FetchError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw FetchError.unexpectedResponse(urlResponse)
        }

        guard let object = try? JSONDecoder().decode(ServerStats.self,
                                                     from: data) else {
            throw FetchError.invalidData
        }

        return object
    }

    /// Generic fetch request that takes only a URL.
    func fetchData(from url: URL) async throws -> Data {
        let session = URLSession(configuration: config())
        let request = URLRequest(url: url)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw FetchError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw FetchError.unexpectedResponse(urlResponse)
        }

        return data
    }

    func fetchData(with request: URLRequest,
                   config: URLSessionConfiguration = NetworkController.baseConfig) async throws -> Data {
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw FetchError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw FetchError.unexpectedResponse(urlResponse)
        }

        return data
    }

    func fetchUsers(url: URL, authentication: String) async throws -> Data {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.clearQueryAndAppend(endpoint: .usersEndpoint)

        var request = URLRequest(url: components.url!)
        request.setUserAgent()

        let config = config(authString: authentication, ocsApiRequest: true)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw FetchError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw FetchError.unexpectedResponse(urlResponse)
        }

        return data
    }

    static func deauthorize(request: URLRequest, config: URLSessionConfiguration) async throws -> Data {
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw FetchError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw FetchError.unexpectedResponse(urlResponse)
        }

        return data
    }

    // MARK: - Helper Methods

    func request(url: URL,
                 with endpoint: Endpoints,
                 appending user: String? = nil) -> URLRequest {
        let url = url
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.clearQueryAndAppend(endpoint: endpoint)

        if let username = user { components.path.append(contentsOf: username) }

        return URLRequest(url: components.url!)
    }

    func config(authString: String? = nil,
                ocsApiRequest: Bool = false) -> URLSessionConfiguration {
        let configuration = NetworkController.baseConfig

        guard let authorizationString = authString else {
            return configuration
        }

        var headers = ["Authorization": authorizationString]

        if ocsApiRequest == true {
            // OCS-APIRequest is needed for legacy (XML based) requests
            headers.updateValue("true",
                                forKey: "OCS-APIRequest")
        } else {
            headers.updateValue("application/json",
                                forKey: "Accept")
        }

        configuration.httpAdditionalHeaders = headers

        return configuration
    }
}

extension URLRequest {
    mutating func setUserAgent() {
        // TODO: Set value to global variable that changes depending on OS
        self.setValue("NextStats for iOS", forHTTPHeaderField: "User-Agent")
    }
}
