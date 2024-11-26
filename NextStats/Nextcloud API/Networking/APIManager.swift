//
//  APIManager.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

final class APIManager: Managable {
    public internal(set) var session = URLSession.shared

    static let shared: Managable = APIManager()

    private init() {}

    func genericRequest(url: URL,
                        httpMethod: ServiceMethod,
                        body: Data? = nil,
                        headers: [String: String]?
    ) async throws -> Data {
        do {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod.rawValue

            if let body = body, httpMethod != .get {
                request.httpBody = body
            }

            if let unwrappedHeaders = headers {
                request.addHeaders(from: unwrappedHeaders)
            }

            request.setUserAgent()

            let (data, response) = try await session.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw APIManagerError.conversionFailedToHTTPURLResponse
            }

            try response.statusCodeChecker()

            return data

        } catch {
            throw APIManagerError.somethingWentWrong(error: error)
        }
    }

    func request<T>(url: URL,
                    httpMethod: ServiceMethod,
                    body: Data?,
                    headers: [String: String]?,
                    expectingReturnType: T.Type,
                    legacyType: Bool = false
    ) async throws -> T where T: Decodable, T: Encodable {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue

        if let body = body, httpMethod != .get {
            request.httpBody = body
        }

        if let unwrappedHeaders = headers {
            request.addHeaders(from: unwrappedHeaders)
        }

        request.setUserAgent()

        guard !legacyType else {
            return try await self.legacyResponseHandler(session.data(for: request))
        }

        return try await self.responseHandler(session.data(for: request))
    }

    /// Decodes responses in JSON for modern requests
    func responseHandler<T: Codable>(_ dataWithResponse: (data: Data, response: URLResponse)) async throws -> T {
        guard let response = dataWithResponse.response as? HTTPURLResponse else {
            throw APIManagerError.conversionFailedToHTTPURLResponse
        }

        try response.statusCodeChecker()

        do {
            return try JSONDecoder().decode(T.self, from: dataWithResponse.data)
        } catch {
            print(error)
            throw APIManagerError.serializaitonFailed
        }
    }

    /// Decodes responses in XML for OCS-API Requests
    func legacyResponseHandler<T: Codable>(_ dataWithResponse: (data: Data, response: URLResponse)) async throws -> T {
        guard let response = dataWithResponse.response as? HTTPURLResponse else {
            throw APIManagerError.conversionFailedToHTTPURLResponse
        }

        try response.statusCodeChecker()

        do {
            return try XMLDecoder().decode(T.self, from: dataWithResponse.data)
        } catch {
            print(error)
            throw APIManagerError.serializaitonFailed
        }
    }
}
