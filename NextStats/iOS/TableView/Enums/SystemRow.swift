//
//  SystemRow.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

/// An enumeration that defines individual rows displayed in the System section of the stats table.

enum SystemRow: Int, TitledSection {
    case cpu, webServer, phpVersion, databaseVersion
    case databaseSize, localCache, distributedCache

    /// A human-readable title for each row.
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

    /// Returns the appropriate display string for the given system and server data.
    ///
    /// - Parameters:
    ///   - server: The `Server` model containing server-level metadata.
    ///   - system: The `System` model containing system-level statistics.
    /// - Returns: A formatted string representing the data for the current row.
    func rowData(server: Server, system: System) -> String {
        switch self {
        case .cpu:
            return formatCPULoad(system.cpuload)
        case .webServer:
            return fallbackText(server.webserver)
        case .phpVersion:
            return fallbackText(server.php?.version)
        case .databaseVersion:
            return databaseVersionText(server.database)
        case .databaseSize:
            return databaseSizeText(server.database)
        case .localCache:
            return fallbackText(system.memcacheLocal)
        case .distributedCache:
            return fallbackText(system.memcacheDistributed)
        }
    }

    // MARK: - Helper Methods

    /// Returns a fallback value or `"N/A"` if the provided string is `nil`.
    private func fallbackText(_ value: String?) -> String {
        return value ?? "N/A"
    }

    /// Formats the CPU load array into a comma-separated string of values rounded to two decimal places.
    ///
    /// - Parameter cpuLoad: An optional array of CPU load values.
    /// - Returns: A formatted string, or `"N/A"` if `cpuLoad` is `nil`.
    private func formatCPULoad(_ cpuLoad: [Double]?) -> String {
        guard let array = cpuLoad else { return "N/A" }
        return array.map {
            String(format: "%.2f", $0)
        }.joined(separator: ", ")
    }

    /// Converts the raw database size value into a human-readable format.
    ///
    /// - Parameter database: An optional `Database` object.
    /// - Returns: A readable size string (e.g., "1.2 GB") or `"N/A"` if unavailable.
    private func databaseSizeText(_ database: Database?) -> String {
        guard let size = database?.size else { return "N/A" }

        switch size {
        case .string(let string):
            guard let intValue = Int(string) else { return "N/A" }
            return Units(bytes: Double(intValue)).getReadableUnit()
        case .int(let int):
            return Units(bytes: Double(int)).getReadableUnit()
        }
    }

    /// Returns the database name and version in a combined string format.
    ///
    /// - Parameter database: An optional `Database` object.
    /// - Returns: A string formatted as `"Type Version"` or `"N/A"` if data is incomplete.
    private func databaseVersionText(_ database: Database?) -> String {
        guard
            let database = database,
            let type = database.type,
            let version = database.version
        else { return "N/A" }
        return "\(type) \(version)"
    }
}
