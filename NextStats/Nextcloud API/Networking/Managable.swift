//
//  Managable.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

protocol Managable {
    func requestDecodable<T: Codable>(
        url: URL,
        httpMethod: ServiceMethod,
        body: Data?,
        headers: [String: String]?,
        isOCSRequest: Bool
    ) async throws -> T

    func requestImageData(
        url: URL,
        httpMethod: ServiceMethod,
        body: Data?,
        headers: [String: String]?
    ) async throws -> Data

    func request(
        url: URL,
        httpMethod: ServiceMethod,
        body: Data?,
        headers: [String: String]?
    ) async throws
}
