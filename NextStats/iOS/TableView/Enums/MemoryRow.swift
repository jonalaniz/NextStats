//
//  MemoryRow.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

/// Represents memory-related rows in the memory section of the stats table.
enum MemoryRow: Int, TitledSection {
    /// Row representing RAM usage.
    case ram

    /// Row representing swap usage.
    case swap

    /// The display title for each memory row.
    ///
    /// Used in table views to label the type of memory being displayed.
    var title: String {
        switch self {
        case .ram: return "Ram"
        case .swap: return "Swap"
        }
    }

    /// Generates `ProgressCellData` used to populate a
    /// `ProgressCell` based on the selected memory type.
    ///
    /// - Parameter system: A `System` object containing
    /// memory information.
    /// - Returns: A `ProgressCellData` object representing
    /// the free and total memory values.
    ///
    /// If any of the required values are missing or invalid, a fallback
    /// `ProgressCellData` with zeroed values and type `
    /// .storage` is returned.
    func memoryCellData(system: System) -> ProgressCellData {
        guard
            let freeMemory = system.memFree?.intValue,
            let totalMemory = system.memTotal?.intValue,
            let freeSwap = system.swapFree?.intValue,
            let totalSwap = system.swapTotal?.intValue
        else {
            return ProgressCellData(
                free: 0, total: 0, type: .storage
            )
        }

        switch self {
        case .ram:
            return ProgressCellData(
                free: freeMemory,
                total: totalMemory,
                type: .memory
            )
        case .swap:
            return ProgressCellData(
                free: freeSwap,
                total: totalSwap,
                type: .swap
            )
        }
    }
}
