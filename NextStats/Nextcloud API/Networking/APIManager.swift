//
//  APIManager.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

final class APIManager: Managable {
    // MARK: - Singleton

    static let shared: Managable = APIManager()
    private init() {}

    // MARK: - Properties

    public internal(set) var session = URLSession.shared

    // MARK: - URL Requests

    /// Performs a network request that does not return a decoded response.
    ///
    /// Use this method for HTTP requests like `DELETE` that do not return data to be decoded.
    ///
    /// - Parameters:
    ///   - url: The endpoint URL.
    ///   - httpMethod: The HTTP method to use (e.g., `.get`, `.post`, `.delete`).
    ///   - body: The HTTP request body as `Data`, if any.
    ///   - headers: Optional headers to include in the request.
    /// - Throws: An `APIManagerError` if the response is invalid or another error occurs.
    func request(url: URL,
                 httpMethod: ServiceMethod,
                 body: Data?,
                 headers: [String: String]?
    ) async throws {
        let request = buildRequest(
            url: url,
            httpMethod: httpMethod,
            body: body,
            headers: headers
        )
        let (data, response) = try await session.data(for: request)
        try validateResponse(data: data, response: response)
    }

    func requestDecodable<T>(url: URL,
                             httpMethod: ServiceMethod,
                             body: Data?,
                             headers: [String: String]?,
                             isOCSRequest: Bool = false
    ) async throws -> T where T: Decodable {
        let request = buildRequest(
            url: url,
            httpMethod: httpMethod,
            body: body,
            headers: headers
        )

        let (data, response) = try await session.data(for: request)
        return try await self.handleResponse(
            data: data,
            response: response,
            legacy: isOCSRequest
        )
    }

    func requestImageData(
        url: URL,
        httpMethod: ServiceMethod,
        body: Data?,
        headers: [String: String]?
    ) async throws -> Data {
        let request = buildRequest(
            url: url,
            httpMethod: httpMethod,
            body: body,
            headers: headers
        )

        let (data, response) = try await session.data(for: request)
        try validateImageResponse(data: data, response: response)

        return data
    }

    // MARK: - Helper Methods

    private func buildRequest(
        url: URL,
        httpMethod: ServiceMethod,
        body: Data?,
        headers: [String: String]?
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue

        if let body = body, httpMethod != .get {
            request.httpBody = body
        }

        request.addHeaders(from: headers)
        request.setUserAgent()

        return request
    }

    private func validateImageResponse(data: Data, response: URLResponse) throws {
        try validateResponse(data: data, response: response)
        guard
            let httpResponse = response as? HTTPURLResponse,
            let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
            contentType.starts(with: "image/")
        else {
            throw APIManagerError.invalidDataType
        }
    }

    /// Validates the HTTP response and throws errors for non-success status codes.
    ///
    /// - Parameters:
    ///   - data: The raw response data.
    ///   - response: The URL response object.
    /// - Throws: An `APIManagerError` if response is not `HTTPURLResponse`, or the status code is not in the 2xx range.
    private func validateResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIManagerError.conversionFailedToHTTPURLResponse
        }

        let statusCode = httpResponse.statusCode

        // Check for Maintenance mode header
        guard httpResponse.value(forHTTPHeaderField: Header.maintenance.key()) == nil
        else { throw APIManagerError.maintenance }

        // Throw statusCode error
        guard (200...299).contains(statusCode) else {
            if statusCode == 401 || statusCode == 403 {
                throw APIManagerError.unauthorized
            }
            throw APIManagerError.invalidResponse(response: httpResponse)
        }
    }

    /// Decodes responses in JSON for modern requests
    /// Decodes responses in XML for OCS-API Requests
    private func handleResponse<T: Decodable>(data: Data, response: URLResponse, legacy: Bool) async throws -> T {
        try validateResponse(data: data, response: response)

        do {
            if legacy {
                return try decodeXML(data)
            } else {
                return try decodeJSON(data)
            }
        } catch {
            throw APIManagerError.serializaitonFailed(error: error)
        }
    }

    /// Decodes raw data into a specified `Decodable` type.
    ///
    /// - Parameter data: The data to decode.
    /// - Returns: A decoded instance of type `T`.
    /// - Throws: A decoding error if the data cannot be decoded.
    private func decodeJSON<T: Decodable>(_ data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func decodeXML<T: Decodable>(_ data: Data) throws -> T {
        return try XMLDecoder().decode(T.self, from: data)
    }
}
