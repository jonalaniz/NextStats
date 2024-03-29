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
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path += Endpoints.login.rawValue

        var request  = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setUserAgent()

        let config = config()
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw NetworkError.unexpectedResponse(urlResponse)
        }

        guard let object = try? JSONDecoder().decode(AuthenticationObject.self,
                                                     from: data) else {
            throw NetworkError.invalidData
        }

        return object
    }

    func fetchServerStatisticsData(url: URL, authentication: String) async throws -> ServerStats {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.clearQueryAndAppend(endpoint: .info)

        var request = URLRequest(url: components.url!)
        request.setUserAgent()

        let config = config(authString: authentication)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw NetworkError.unexpectedResponse(urlResponse)
        }

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

        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw NetworkError.unexpectedResponse(urlResponse)
        }

        return data
    }

    func fetchData(with request: URLRequest,
                   config: URLSessionConfiguration = NetworkController.baseConfig) async throws -> Data {
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw NetworkError.unexpectedResponse(urlResponse)
        }

        return data
    }

    func fetchUsers(url: URL, authentication: String) async throws -> Data {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.clearQueryAndAppend(endpoint: .users)

        var request = URLRequest(url: components.url!)
        request.setUserAgent()

        let config = config(authString: authentication, ocsApiRequest: true)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw NetworkError.unexpectedResponse(urlResponse)
        }

        return data
    }

    func post(user data: Data, url: URL, authenticaiton: String) async throws -> Response {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.clearQueryAndAppend(endpoint: .users)

        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setUserAgent()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let config = config(authString: authenticaiton, ocsApiRequest: true)
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw NetworkError.unexpectedResponse(urlResponse)
        }

        guard let response = try? XMLDecoder().decode(Response.self, from: data)
        else {
            let string = String(data: data, encoding: .utf8)!
            throw NetworkError.invalidData
        }

        return response
    }

    func deauthorize(at url: URL, config: URLSessionConfiguration) async throws -> Data {
        let session = URLSession(configuration: config)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (data, response) = try await session.data(for: request)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkError.missingResponse
        }

        guard (200...299).contains(urlResponse.statusCode) else {
            throw NetworkError.unexpectedResponse(urlResponse)
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
        let osName: String

        switch UIDevice.current.userInterfaceIdiom {
        case .phone: osName = "iOS"
        case .pad: osName = "iPadOS"
        case .tv: osName = "tvOS"
        case .carPlay: osName = "carPlay"
        case .mac: osName = "macOS"
        case .vision: osName = "visionOS"
        default: osName = "¯\\_(ツ)_/¯"
        }

        self.setValue("NextStats for \(osName)", forHTTPHeaderField: "User-Agent")
    }
}
