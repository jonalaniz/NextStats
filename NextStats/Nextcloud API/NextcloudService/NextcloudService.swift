//
//  NextcloudService.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/11/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

final class NextcloudService {

    // MARK: - Singleton

    static let shared = NextcloudService()
    private init() {}

    // MARK: - Properties

    private let apiManager = APIManager.shared
    private let session = URLSession(configuration: .default)

    // MARK: - Public API

    func deauthorize(
        server: NextServer
    ) async throws -> GenericResponse {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString,
            endpoint: .appPassword
        )
        let headers = buildHeaders(
            authorization: server.authenticationString(),
            ocsApiRequest: true
        )

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .delete,
            body: nil,
            headers: headers,
            isOCSRequest: true
        )
    }

    func fetchAuthenticationData(
        url: URL
    ) async throws -> AuthenticationObject {
        let urlWithEndpoint = try buildURL(url, with: .login)

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .post,
            body: nil,
            headers: nil,
            isOCSRequest: false
        )
    }

    /// Generic fetch request that takes only a URL, returns data
    func fetchImageData(from url: URL) async throws -> Data {
        return try await apiManager.requestImageData(
            url: url,
            httpMethod: .get,
            body: nil,
            headers: nil
        )
    }

    func fetchLoginObject(
        from url: URL, with token: String
    ) async throws -> LoginObject {
        let body = Data("token=\(token)".utf8)

        return try await apiManager.requestDecodable(
            url: url,
            httpMethod: .post,
            body: body,
            headers: nil,
            isOCSRequest: false
        )
    }

    func fetchStatistics(for server: NextServer) async throws -> ServerStats {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString, endpoint: .info
        )
        let headers = buildHeaders(
            authorization: server.authenticationString(),
            ocsApiRequest: false
        )

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .get,
            body: nil,
            headers: headers,
            isOCSRequest: false
        )
    }

    func fetchGroups(
        for server: NextServer
    ) async throws -> GroupsObject {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString, endpoint: .groups
        )
        let headers = buildHeaders(
            authorization: server.authenticationString(),
            ocsApiRequest: true
        )

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint,
            httpMethod: .get,
            body: nil,
            headers: headers,
            isOCSRequest: true
        )
    }

    func fetchUsers(
        for server: NextServer
    ) async throws -> Users {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString,
            endpoint: .user
        )
        let headers = buildHeaders(
            authorization: server.authenticationString(),
            ocsApiRequest: true
        )

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint,
            httpMethod: .get,
            body: nil,
            headers: headers,
            isOCSRequest: true
        )
    }

    func fetchUser(
        _ user: String, in server: NextServer
    ) async throws -> User {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString,
            endpoint: .user, path: user
        )
        let headers = buildHeaders(
            authorization: server.authenticationString(),
            ocsApiRequest: true
        )

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .get,
            body: nil,
            headers: headers,
            isOCSRequest: true
        )
    }

    func ping(_ url: URL) async throws {
        return try await apiManager.request(
            url: url,
            httpMethod: .get,
            body: nil,
            headers: nil
        )
    }

    func postUser(
        _ data: Data, in server: NextServer
    ) async throws -> GenericResponse {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString, endpoint: .user
        )
        var headers = buildHeaders(authorization: server.authenticationString(),
                                   ocsApiRequest: true)
        headers[Header.contentType.key()] = Header.contentType.value()

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .post,
            body: data,
            headers: headers,
            isOCSRequest: true
        )
    }

    func toggleUser(
        _ path: String, in server: NextServer, type: ToggleType
    ) async throws -> GenericResponse {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString, endpoint: .user, path: path
        )
        let headers = buildHeaders(
            authorization: server.authenticationString(),
            ocsApiRequest: true
        )

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: type.httpMethod,
            body: nil,
            headers: headers,
            isOCSRequest: true
        )
    }

    func wipeStatus(
        for server: NextServer
    ) async throws -> WipeObject {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString, endpoint: .wipeCheck
        )
        let body = Data("token=\(server.password)".utf8)

        return try await apiManager.requestDecodable(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .post,
            body: body,
            headers: nil,
            isOCSRequest: false
        )
    }

    func postWipe(_ server: NextServer) async throws {
        let urlWithEndpoint = try buildURLFrom(
            string: server.URLString, endpoint: .wipeCheck
        )
        let body = Data("token=\(server.password)".utf8)

        try await apiManager.request(
            url: urlWithEndpoint,
            httpMethod: .post,
            body: body,
            headers: nil
        )
    }

    // MARK: - Helper Functions

    private func buildURLFrom(
        string: String,
        endpoint: Endpoint,
        path: String? = nil)
    throws -> URL {
        guard let baseURL = URL(string: string) else {
            throw APIManagerError.invalidURL
        }

        guard let path else {
            return try buildURL(baseURL, with: endpoint)
        }

        return try buildURLWithPath(baseURL, with: endpoint, path: path)
    }

    private func buildURL(
        _ baseURL: URL, with endpoint: Endpoint
    ) throws -> URL {
        return baseURL.appendingPathComponentSafely(
            endpoint.rawValue
        )
    }

    private func buildURLWithPath(
        _ baseURL: URL, with endpoint: Endpoint, path: String
    ) throws -> URL {
        return baseURL.appendingPathComponentSafely(
            endpoint.rawValue + "/" + path
        )
    }

    private func buildHeaders(
        authorization: String, ocsApiRequest: Bool
    ) -> [String: String] {
        var headers = [Header.authorization.key(): authorization]
        headers.updateValue(
            ocsApiRequest ? Header.ocsAPIRequest.value() : Header.acceptJSON.value(),
            forKey: ocsApiRequest ? Header.ocsAPIRequest.key() : Header.acceptJSON.key()
        )

        return headers
    }

}
