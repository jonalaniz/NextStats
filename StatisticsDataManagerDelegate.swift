//
//  StatisticsDataManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.

import Foundation

enum DataManagerError {
    case unableToParseJSON
    case missingData

    public var description: String {
        switch self {
        case .missingData: return .localized(.missingData)
        case .unableToParseJSON: return .localized(.unableToParseJSON)
        }
    }
}

/// Calls relating to fetching and updating data in the `StatisticsDataManager`
protocol StatisticsDataManagerDelegate: AnyObject {
    func dataUpdated()
    func failedToFetchData(error: FetchError)
    func failedToUpdateData(error: DataManagerError)
    func willBeginFetchingData()
}
