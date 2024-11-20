//
//  NXStatsManager+UITableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/29/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

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
    case cpu = 0, webServer, PHPVersion, databaseVersion, databaseSize, localCache, distributedCache
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

extension NXStatsManager: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StatsSection(rawValue: indexPath.section)?.rowHeight ?? 0
    }

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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")

        guard
            let cellRow = SystemRow(rawValue: row),
            let system = stats.nextcloud?.system
        else { return cell }

        switch cellRow {
        case .cpu: configureCell(cell, text: "CPU", secondaryText: cpuLoadAverages())
        case .webServer: configureCell(cell, text: "Web Server", secondaryText: stats.server?.webserver)
        case .PHPVersion: configureCell(cell, text: "PHP Version", secondaryText: stats.server?.php?.version)
        case .databaseVersion: configureCell(cell, text: "Database", secondaryText: databaseVersion())
        case .databaseSize: configureCell(cell, text: "Database Size", secondaryText: databaseSize())
        case .localCache: configureCell(cell, text: "Local Cache", secondaryText: system.memcacheLocal)
        case .distributedCache: configureCell(
            cell, text: "Distributed Cache",
            secondaryText: system.memcacheDistributed)
        }

        return cell
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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")

        guard let cellRow = StorageRow(rawValue: row)
        else { return cell }

        switch cellRow {
        case .space: configureCell(cell, text: "Free Space", secondaryText: freeSpace())
        case .files: configureCell(cell, text: "Number of Files", secondaryText: numberOfFiles())
        }

        return cell
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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")

        guard let cellRow = ActivityRow(rawValue: row)
        else { return cell }

        switch cellRow {
        case .last5: configureCell(cell, text: "Last 5 Minutes", secondaryText: activityValue(for: cellRow))
        case .lastHour: configureCell(cell, text: "Last Hour", secondaryText: activityValue(for: cellRow))
        case .lastDay: configureCell(cell, text: "Last Day", secondaryText: activityValue(for: cellRow))
        case .total: configureCell(cell, text: "Total Users", secondaryText: activityValue(for: cellRow))
        }

        return cell
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

    private func configureCell(_ cell: UITableViewCell, text: String, secondaryText: String?) {
        var content = cell.defaultContentConfiguration()
        content.text = text
        content.secondaryText = secondaryText ?? "N/A"
        content.textProperties.color = .theme
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.selectionStyle = .none
    }
}
