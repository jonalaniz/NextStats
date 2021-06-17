//
//  StatisticsDataManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

/// Calls relating to fetching and updating data in the `StatisticsDataManager`
protocol StatisticsDataManagerDelegate: AnyObject {
    func fetchingDidBegin()
    func errorFetchingData(error: FetchError)
    func dataUpdated()
    func errorUpdatingData()
}
