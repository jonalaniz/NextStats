//
//  ErrorHandler.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/18/22.
//  Copyright © 2022 Jon Alaniz. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case error(String) // Sends error.localizedDescription
    case invalidData // Is this redundant?
    case invalidURL
    case missingResponse
    case unexpectedResponse(HTTPURLResponse)

    var title: String {
        switch self {
        case .error(_): return .localized(.errorTitle)
        case .invalidData: return .localized(.invalidData)
        case .invalidURL: return .localized(.networkError)
        case .missingResponse: return .localized(.missingResponse)
        case .unexpectedResponse(_): return .localized(.unauthorized)
        }
    }

    var description: String {
        switch self {
        case .error(let description): return description
        case .invalidData: return .localized(.invalidDataDescription)
        case .invalidURL: return .localized(.networkError)
        case .missingResponse: return .localized(.missingResponseDescription)
        case .unexpectedResponse(_): return .localized(.unexpectedResponse)
        }
    }
}

protocol ErrorHandler: AnyObject {
    func handle(error type: NetworkError)
}
