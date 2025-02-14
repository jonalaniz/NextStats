//
//  NXStatsManager+UITableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/29/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

// TODO: Move this out
enum StatsSection: Int, CaseIterable {
    case system = 0, memory, storage, activity

    var rowHeight: CGFloat {
        switch self {
        case .memory: return 66
        default: return 44
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
    case ram = 0, swap
}

enum StorageRow: Int, CaseIterable {
    case space = 0, files
}

enum ActivityRow: Int, CaseIterable {
    case last5 = 0, lastHour, lastDay, total
}

extension NXStatsManager: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return StatsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = StatsSection(rawValue: section)
        else { return 0 }

        switch tableSection {
        case .system: return SystemRow.allCases.count
        case .memory: return MemoryRow.allCases.count
        case .storage: return StorageRow.allCases.count
        case .activity: return ActivityRow.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = StatsSection(rawValue: indexPath.section)
        else { return UITableViewCell() }

        switch tableSection {
        case .system: return systemCell(row: indexPath.row)
        case .memory: return memoryCell(row: indexPath.row)
        case .storage: return storageCell(row: indexPath.row)
        case .activity: return activityCell(row: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tableSection = StatsSection(rawValue: section)
        else { return nil }

        switch tableSection {
        case .system: return "Nextcloud \(versionNumber())"
        case .memory: return "Memory"
        case .storage: return "Storage"
        case .activity: return "Active Users"
        }
    }

    // MARK: - Helper Functions
    private func versionNumber() -> String {
        guard let number = stats.nextcloud?.system?.version
        else { return "" }

        return number
    }

    private func systemCell(row: Int) -> UITableViewCell {
        guard
            let cellRow = SystemRow(rawValue: row),
            let system = stats.nextcloud?.system
        else { return UITableViewCell() }

        let secondaryText: String

        switch cellRow {
        case .cpu: secondaryText = cpuLoadAverages()
        case .webServer: secondaryText = stats.server?.webserver ?? "N/A"
        case .phpVersion: secondaryText = stats.server?.php?.version ?? "N/A"
        case .databaseVersion: secondaryText = databaseVersion()
        case .databaseSize: secondaryText = databaseSize()
        case .localCache: secondaryText = system.memcacheLocal ?? "N/A"
        case .distributedCache: secondaryText = system.memcacheDistributed ?? "N/A"
        }

        return configureCell(text: cellRow.title, secondaryText: secondaryText)
    }

    private func cpuLoadAverages() -> String {
        guard let usageArray = stats.nextcloud?.system?.cpuload
        else { return "N/A "}

        let stringArray = usageArray.map { String(format: "%.2f", $0) }

        return stringArray.joined(separator: ", ")
    }

    private func databaseVersion() -> String {
        guard let server = stats.server,
              let database = server.database?.type,
              let dbVersion = server.database?.version
        else { return "N/A" }

        return "\(database) \(dbVersion)"
    }

    private func databaseSize() -> String {
        guard let size = stats.server?.database?.size
        else { return "N/A" }

        switch size {
        case .string(let string):
            guard let intValue = Int(string)
            else { return "N/A" }

            return Units(bytes: Double(intValue)).getReadableUnit()
        case .int(let int):
            return Units(bytes: Double(int)).getReadableUnit()
        }
    }

    private func memoryCell(row: Int) -> ProgressCell {
        let cell: ProgressCell
        let memory: (Int?, Int?)
        let type: ProgressCellIcon
        let cellRow = MemoryRow(rawValue: row)!

        switch cellRow {
        case .ram:
            memory = ram()
            type = .memory
        case .swap:
            memory = swap()
            type = .swap
        }

        guard memory.0 != nil, memory.1 != nil
        else {
            cell = ProgressCell(free: 0, total: 0, type: type)
            return cell
        }

        cell = ProgressCell(free: memory.0!, total: memory.1!, type: type)

        return cell
    }

    private func ram() -> (Int?, Int?) {
        let free = stats.nextcloud?.system?.memFree?.intValue
        let total = stats.nextcloud?.system?.memTotal?.intValue
        return (free, total)
    }

    private func swap() -> (Int?, Int?) {
        let free = stats.nextcloud?.system?.swapFree?.intValue
        let total = stats.nextcloud?.system?.swapTotal?.intValue
        return (free, total)
    }

    private func storageCell(row: Int) -> UITableViewCell {
        guard let cellRow = StorageRow(rawValue: row)
        else { return UITableViewCell() }

        switch cellRow {
        case .space:
            return configureCell(text: "Free Space",
                                 secondaryText: freeSpace())
        case .files:
            return configureCell(text: "Number of Files",
                                 secondaryText: numberOfFiles())
        }
    }

    private func freeSpace() -> String {
        guard let freeSpace = stats.nextcloud?.system?.freespace
        else { return "N/A"}

        let doubleFreeSpace = Double(freeSpace)

        guard
            !doubleFreeSpace.isNaN,
            !doubleFreeSpace.isInfinite
        else { return "N/A" }

        return Units(bytes: doubleFreeSpace).getReadableUnit()

    }

    private func numberOfFiles() -> String {
        guard let number = stats.nextcloud?.storage?.numFiles
        else { return "N/A" }

        return String(number)
    }

    private func activityCell(row: Int) -> UITableViewCell {
        guard let cellRow = ActivityRow(rawValue: row)
        else { return UITableViewCell() }

        let text: String

        switch cellRow {
        case .last5: text = "Last 5 Minutes"
        case .lastHour: text = "Last Hour"
        case .lastDay: text = "Last Day"
        case .total: text = "Total Users"
        }

        return configureCell(text: text,
                             secondaryText: activityValue(for: cellRow))
    }

    private func activityValue(for row: ActivityRow) -> String {
        guard
            let last5 = stats.activeUsers?.last5Minutes,
            let lastHour = stats.activeUsers?.last1Hour,
            let lastDay = stats.activeUsers?.last24Hours,
            let total = stats.nextcloud?.storage?.numUsers
        else { return "N/A "}

        switch row {
        case .last5: return String(last5)
        case .lastHour: return String(lastHour)
        case .lastDay: return String(lastDay)
        case .total: return String(total)
        }
    }

    private func configureCell(text: String, secondaryText: String) -> UITableViewCell {
        return BaseTableViewCell(style: .value1,
                                 text: text,
                                 textColor: .theme,
                                 secondaryText: secondaryText)
    }
}
