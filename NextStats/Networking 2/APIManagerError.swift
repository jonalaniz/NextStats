//
//  APIManagerError.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

protocol ErrorHandling: AnyObject {
    func handleError(_ error: APIManagerError)
}

enum APIManagerError: Error {
    case configurationMissing
    case conversionFailedToHTTPURLResponse
    case invalidResponse(statuscode: Int)
    case invalidURL
    case serializaitonFailed
    case somethingWentWrong(error: Error?)

    var localizedDescription: String {
        switch self {
        case .configurationMissing: return .localized(.authorizationDataMissing)
        case .conversionFailedToHTTPURLResponse: return .localized(.missingResponse)
        case .invalidResponse(let statuscode): return "\(String.localized(.unexpectedResponse)) (\(statuscode))"
        case .invalidURL: return .localized(.serverFormEnterValidAddress)
        case .serializaitonFailed: return .localized(.failedToSerializeResponse)
        case .somethingWentWrong(let error): return error?.localizedDescription ?? "Unknown Error"
        }
    }
}
