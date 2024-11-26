//
//  Managable.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

protocol Managable {
    func request<T: Codable>(url: URL,
                             httpMethod: ServiceMethod,
                             body: Data?,
                             headers: [String: String]?,
                             expectingReturnType: T.Type,
                             legacyType: Bool
    ) async throws -> T

    func genericRequest(url: URL,
                        httpMethod: ServiceMethod,
                        body: Data?,
                        headers: [String: String]?
    ) async throws -> Data
}
