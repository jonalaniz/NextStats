//
//  StatsSection.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/14/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum StatsSection: Int, CaseIterable {
    case system, memory, storage, activity

    var rowHeight: CGFloat {
        switch self {
        case .memory: return 66
        default: return 44
        }
    }

    var rows: Int {
        switch self {
        case .system: return SystemRow.allCases.count
        case .memory: return MemoryRow.allCases.count
        case .storage: return StorageRow.allCases.count
        case .activity: return ActivityRow.allCases.count
        }
    }

    func header(version: String?) -> String {
        switch self {
        case .system: return "System" + (version.map { " (\($0))" } ?? "")
        case .memory: return "Memory"
        case .storage: return "Storage"
        case .activity: return "Activity"
        }
    }
}

enum SystemRow: Int, CaseIterable {
    case cpu, webServer, phpVersion, databaseVersion, databaseSize, localCache, distributedCache

    var title: String {
        switch self {
        case .cpu: return "CPU"
        case .webServer: return "Web Server"
        case .phpVersion: return "PHP Version"
        case .databaseVersion: return "Database Version"
        case .databaseSize: return "Database Size"
        case .localCache: return "Local Cache"
        case .distributedCache: return "Distributed Cache"
        }
    }
}

enum MemoryRow: Int, CaseIterable {
    case ram, swap
}

enum StorageRow: Int, CaseIterable {
    case space, files

    var title: String {
        switch self {
        case .space: return "Free Space"
        case .files: return "Number of Files"
        }
    }
}

enum ActivityRow: Int, CaseIterable {
    case last5, lastHour, lastDay, total

    var title: String {
        switch self {
        case .last5: return "Last 5 Minutes"
        case .lastHour: return "Last Hour"
        case .lastDay: return "Last Day"
        case .total: return "Total"
        }
    }
}
