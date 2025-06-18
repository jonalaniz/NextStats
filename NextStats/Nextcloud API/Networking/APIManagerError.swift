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
    case invalidResponse(response: HTTPURLResponse)
    case invalidURL
    case maintenance
    case serializaitonFailed(error: Error)
    case somethingWentWrong(error: Error)

    var localizedDescription: String {
        switch self {
        case .configurationMissing:
            return .localized(.authorizationDataMissing)
        case .conversionFailedToHTTPURLResponse:
            return .localized(.missingResponse)
        case .invalidResponse(let statuscode):
            return "\(String.localized(.unexpectedResponse)) (\(statuscode))"
        case .invalidURL:
            return .localized(.serverFormEnterValidAddress)
        case .maintenance:
            return .localized(.maintenanceDescription)
        case .serializaitonFailed(let error):
            return error.localizedDescription
        case .somethingWentWrong(let error):
            return error.localizedDescription
        }
    }
}
