//
//  NextStatsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/21/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

/// Facilitates the fetching and parsing of OCS objects into NextStat objects
class NextStatsDataManager {
    /// Returns the shared `StatisticsDataManager` instance
    public static let shared = NextStatsDataManager()

    private let networkController = NetworkController.shared
    private var nextStat = NextStat()
    weak var delegate: DataManagerDelegate?

    var server: NextServer? {
        didSet {
            // Here we will reset our nextStat and begin fetching.
        }
    }
}
