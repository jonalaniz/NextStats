//
//  NXDataManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

enum DataManagerError {
    case unableToParseData
    case missingData

    public var description: String {
        switch self {
        case .missingData: return .localized(.missingData)
        case .unableToParseData: return .localized(.unableToParseData)
        }
    }
}

/// Calls relating to fetching and updating data in Data Managers`
/// THIS NEEDS TO BE REPLACED SOON 
protocol DataManagerDelegate: AnyObject {
    func dataUpdated()
    func failedToFetchData(error: FetchError)
    func failedToUpdateData(error: DataManagerError)
    func didBeginFetchingData()
}

protocol NXDataManagerDelegate: AnyObject {
    func stateDidChange(_ dataManagerState: NXDataManagerState)
}

enum NXDataManagerState {
    case fetchingData
    case parsingData
    case failed(NXDataManagerError)
    case statsCaptured
}

enum NXDataManagerError {
    case networkError(FetchError)
    case unableToDecode
    case missingData

    public var description: String {
        switch self {
        case .missingData: return .localized(.missingData)
        case .unableToDecode: return .localized(.unableToParseData)
        default: return "Generic Error"
        }
    }
}
