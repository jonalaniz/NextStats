//
//  NextcloudService.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/11/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

final class NextcloudService {
    static let shared = NextcloudService()

    private let apiManager = APIManager.shared
    private let session = URLSession(configuration: .default)

    private init() {}

    // MARK: - Public API
    func deauthorize(server: NextServer) async throws -> GenericResponse {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .appPassword)
        let headers = buildHeaders(authorization: server.authenticationString(),
                                   ocsApiRequest: true)

        return try await apiManager.request(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .delete,
            body: nil,
            headers: headers,
            expectingReturnType: GenericResponse.self,
            legacyType: true
        )
    }

    func fetchAuthenticationData(url: URL) async throws -> AuthenticationObject {
        let urlWithEndpoint = try buildURL(url, with: .login)

        return try await apiManager.request(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .post,
            body: nil,
            headers: nil,
            expectingReturnType: AuthenticationObject.self,
            legacyType: false
        )
    }

    /// Generic fetch request that takes only a URL, returns data
    func fetchData(from url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIManagerError.invalidURL
        }

        try httpResponse.statusCodeChecker()

        return data
    }

    func fetchLoginObject(from url: URL, with token: String) async throws -> LoginObject {
        let body = "token=\(token)".data(using: .utf8)

        return try await apiManager.request(
            url: url,
            httpMethod: .post,
            body: body,
            headers: nil,
            expectingReturnType: LoginObject.self,
            legacyType: false
        )
    }

    func fetchStatistics(for server: NextServer) async throws -> ServerStats {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .info)
        let headers = buildHeaders(authorization: server.authenticationString(),
                                   ocsApiRequest: false)

        return try await apiManager.request(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .get,
            body: nil,
            headers: headers,
            expectingReturnType: ServerStats.self,
            legacyType: false
        )
    }

    func fetchGroups(for server: NextServer) async throws -> GroupsObject {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .groups)
        let headers = buildHeaders(authorization: server.authenticationString(), ocsApiRequest: true)

        return try await apiManager.request(
            url: urlWithEndpoint,
            httpMethod: .get,
            body: nil,
            headers: headers,
            expectingReturnType: GroupsObject.self,
            legacyType: true
        )
    }

    func fetchUsers(for server: NextServer) async throws -> Users {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .users)
        let headers = buildHeaders(authorization: server.authenticationString(),
                                   ocsApiRequest: true)

        return try await apiManager.request(
            url: urlWithEndpoint,
            httpMethod: .get,
            body: nil,
            headers: headers,
            expectingReturnType: Users.self,
            legacyType: true
        )
    }

    func fetchUser(_ user: String, in server: NextServer) async throws -> User {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .user, path: user)
        let headers = buildHeaders(authorization: server.authenticationString(),
                                   ocsApiRequest: true)

        return try await apiManager.request(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .get,
            body: nil,
            headers: headers,
            expectingReturnType: User.self,
            legacyType: true
        )
    }

    func postUser(_ data: Data, in server: NextServer) async throws -> GenericResponse {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .users)
        var headers = buildHeaders(authorization: server.authenticationString(),
                                   ocsApiRequest: true)
        headers[Header.contentType.key()] = Header.contentType.value()

        return try await apiManager.request(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .post,
            body: data,
            headers: headers,
            expectingReturnType: GenericResponse.self,
            legacyType: true
        )
    }

    func toggleUser(_ path: String, in server: NextServer, type: ToggleType) async throws -> GenericResponse {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .user, path: path)
        let headers = buildHeaders(authorization: server.authenticationString(),
                                   ocsApiRequest: true)
        let httpMethod = type == .disable ? ServiceMethod.put : ServiceMethod.delete

        return try await apiManager.request(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: httpMethod,
            body: nil,
            headers: headers,
            expectingReturnType: GenericResponse.self,
            legacyType: true
        )
    }

    func wipeStatus(for server: NextServer) async throws -> WipeObject {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .wipeCheck)
        let body = "token=\(server.password)".data(using: .utf8)

        return try await apiManager.request(
            url: urlWithEndpoint.absoluteURL,
            httpMethod: .post,
            body: body,
            headers: nil,
            expectingReturnType: WipeObject.self,
            legacyType: false
        )
    }

    func postWipe(_ server: NextServer) async throws {
        let urlWithEndpoint = try buildURLFrom(string: server.URLString, endpoint: .wipeCheck)
        let body = "token=\(server.password)".data(using: .utf8)

        _ = try await apiManager.genericRequest(url: urlWithEndpoint,
                                                httpMethod: .post,
                                                body: body,
                                                headers: nil)

    }

    // MARK: - Utilities
    private func buildURLFrom(string: String,
                              endpoint: Endpoint,
                              path: String? = nil) throws -> URL {
        guard let baseURL = URL(string: string) else {
            throw APIManagerError.invalidURL
        }

        guard let path else {
            return try buildURL(baseURL, with: endpoint)
        }

        return try buildURLWithPath(baseURL, with: endpoint, path: path)
    }

    private func buildURL(_ baseURL: URL, with endpoint: Endpoint) throws -> URL {
        guard let endpointURL = endpoint.url(relativeTo: baseURL) else {
            throw APIManagerError.invalidURL
        }

        return endpointURL
    }

    private func buildURLWithPath(_ baseURL: URL, with endpoint: Endpoint, path: String) throws -> URL {
        guard let endpointURL = endpoint.url(relativeTo: baseURL, appending: path) else {
            throw APIManagerError.invalidURL
        }

        return endpointURL
    }

    private func buildHeaders(authorization: String, ocsApiRequest: Bool) -> [String: String] {
        var headers = [Header.authorization.key(): authorization]
        headers.updateValue(
            ocsApiRequest ? Header.ocsAPIRequest.value() : Header.acceptJSON.value(),
            forKey: ocsApiRequest ? Header.ocsAPIRequest.key() : Header.acceptJSON.key()
        )

        return headers
    }

}
