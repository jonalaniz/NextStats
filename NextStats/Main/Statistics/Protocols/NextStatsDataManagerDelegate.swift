//
//  StatisticsDataManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.

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

protocol NextDataManagerDelegate: AnyObject {
    func stateDidChange(_ dataManagerState: NSDataManagerState)
}

enum NSDataManagerState {
    case fetchingData
    case parsingData
    case failed(NextDataManagerError)
    case statsCaptured
}

enum NextDataManagerError {
    case networkError(FetchError)
    case unableToDecode
    case missingData
}
