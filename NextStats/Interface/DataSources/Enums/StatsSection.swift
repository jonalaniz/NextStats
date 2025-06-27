//
//  StatsSection.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/14/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

/// Represents the different sections of a stats table view.
enum StatsSection: Int, CaseIterable {
    /// The system section, displaying general system information.
    case system

    /// The memory section, showing memory-related metrics.
    case memory

    /// The storage section, detailing storage usage and capacity.
    case storage

    /// The activity section, indicating user activity statistics.
    case activity

    /// The row height for the section.
    ///
    /// - Returns: A `CGFloat` value representing the row height for cells in this section.
    ///            Memory rows are taller to accommodate progress views.
    var rowHeight: CGFloat {
        switch self {
        case .memory: return 66
        default: return 44
        }
    }

    /// The number of rows associated with this section.
    ///
    /// - Returns: The count of rows defined by the associated enum for this section.
    var rows: Int {
        switch self {
        case .system: return SystemRow.allCases.count
        case .memory: return MemoryRow.allCases.count
        case .storage: return StorageRow.allCases.count
        case .activity: return ActivityRow.allCases.count
        }
    }

    /// Returns the localized header title for the section.
    ///
    /// - Parameter version: An optional version string, used for system section headers.
    /// - Returns: A string to be used as the section header title.
    func header(version: String?) -> String {
        switch self {
        case .system: return "System" + (version.map { " (\($0))" } ?? "")
        case .memory: return "Memory"
        case .storage: return "Storage"
        case .activity: return "Activity"
        }
    }
}
