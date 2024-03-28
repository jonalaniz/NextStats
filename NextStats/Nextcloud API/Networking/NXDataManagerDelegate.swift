//
//  NXDataManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

protocol NXDataManagerDelegate: AnyObject {
    func stateDidChange(_ dataManagerState: NXDataManagerState)
}

enum NXDataManagerState {
    case fetchingData
    case parsingData
    case failed(NXDataManagerError)
    case dataCaptured
}

enum NXDataManagerError {
    case networkError(NetworkError)
    case unableToDecode // Will this catch `missindData` and `invalidData`?
    case missingData // Possibly redundant?

    public var description: String {
        switch self {
        case .missingData: return .localized(.missingData)
        case .unableToDecode: return .localized(.unableToParseData)
        default: return "Generic Error"
        }
    }
}
