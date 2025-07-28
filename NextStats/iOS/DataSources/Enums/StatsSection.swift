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
    var rowHeight: CGFloat? {
        switch self {
        case .memory: return 66
        default: return nil
        }
    }

    /// Returns the localized header title for the section.
    ///
    /// - Parameter version: An optional version string, used for system section headers.
    /// - Returns: A string to be used as the section header title.
    func header(version: String?) -> String {
        switch self {
        case .system:
            return "System" + (version.map { " (\($0))" } ?? "")
        case .memory: return "Memory"
        case .storage: return "Storage"
        case .activity: return "Activity"
        }
    }
}
