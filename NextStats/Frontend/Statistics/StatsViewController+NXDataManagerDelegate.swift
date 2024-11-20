//
//  StatsViewController+NXDataManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/20/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension StatsViewController: NXDataManagerDelegate {
    func stateDidChange(_ dataManagerState: NXDataManagerState) {
        switch dataManagerState {
        case .fetchingData:
            showLoadingView()
        case .parsingData:
            print("Parsing Data")
        case .dataCaptured:
            showTableView()
        }
    }
}
