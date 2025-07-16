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
    /// The required configuration data (e.g. API key) is missing
    case configurationMissing

    /// The `URLResponse` could not be typecast to `HTTPURLResponse`.
    case conversionFailedToHTTPURLResponse

    case dataEmpty

    /// The server returned an HTTP status code outside the success range (200-299)
    /// and does not match a known Error code.
    case invalidResponse(response: HTTPURLResponse)

    /// The server returned a different data type than what was requested.
    case invalidDataType

    /// The provided RUL was invalid or malformed.
    case invalidURL

    /// The server is currently in maintenance mode.
    case maintenance

    /// The response could not be decoded into the expected model.
    ///  - Parameter: `Error` is usually a `DecodingError` from `JSONDecorder`
    ///  or `XMLDecoder`
    case serializaitonFailed(error: Error)

    /// A general catch-all error when the cause is unknown
    case somethingWentWrong(error: Error)

    case unauthorized

    var description: String {
        switch self {
        case .configurationMissing:
            return .localized(.authorizationDataMissing)
        case .conversionFailedToHTTPURLResponse:
            return .localized(.missingResponse)
        case .dataEmpty: return "Server returned empty response."
        case .invalidResponse(let statuscode):
            return "\(String.localized(.unexpectedResponse)) (\(statuscode))"
        case .invalidDataType: return "Invalid data type response."
        case .invalidURL:
            return .localized(.serverFormEnterValidAddress)
        case .maintenance:
            return .localized(.maintenanceDescription)
        case .serializaitonFailed(let error):
            return error.localizedDescription
        case .somethingWentWrong(let error):
            return error.localizedDescription
        case .unauthorized: return "Unauthorized"
        }
    }

    var title: String {
        switch self {
        case .configurationMissing: .localized(.missingResponse)
        case .conversionFailedToHTTPURLResponse: .localized(.missingResponse)
        case .dataEmpty: .localized(.missingData)
        case .invalidResponse(let response): "Unexpected Response: \(response.statusCode)"
        case .invalidDataType: .localized(.invalidData)
        case .invalidURL: .localized(.errorTitle)
        case .maintenance: .localized(.maintenanceMode)
            // swiftlint:disable:next empty_enum_arguments
        case .serializaitonFailed(_): .localized(.errorTitle)
            // swiftlint:disable:next empty_enum_arguments
        case .somethingWentWrong(_): .localized(.errorTitle)
        case .unauthorized: "You are unauthorized to access this Server"
        }
    }
}
