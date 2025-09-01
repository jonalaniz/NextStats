//
//  ProgressCellData.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

struct ProgressCellData {
    let free: Int
    let total: Int
    let type: ProgressCellIcon

    static func noData() -> ProgressCellData {
        return ProgressCellData(free: -1, total: -1, type: .storage)
    }
}
