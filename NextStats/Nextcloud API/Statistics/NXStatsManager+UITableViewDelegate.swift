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

    func height() -> CGFloat {
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
        guard let tableSection = StatsSection(rawValue: indexPath.section)
        else { return 0 }

        return tableSection.height()
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

        guard let cellRow = SystemRow(rawValue: row)
        else { return cell }

        var content = cell.defaultContentConfiguration()

        switch cellRow {
        case .cpu:
            content.text = "CPU"
            content.secondaryText = cpuLoadAverages()
        case .webServer:
            content.text = "Web Server"
            content.secondaryText = stats.server?.webserver ?? "N/A"
        case .PHPVersion:
            content.text = "PHP Version"
            content.secondaryText = stats.server?.php?.version ?? "N/A"
        case .databaseVersion:
            content.text = "Database"
            content.secondaryText = databaseVersion()
        case .databaseSize:
            content.text = "Database Size"
            content.secondaryText = databaseSize()
        case .localCache:
            content.text = "Local Cache"
            content.secondaryText = stats.nextcloud?.system?.memcacheLocal ?? "N/A"
        case .distributedCache:
            content.text = "Distributed Cache"
            content.secondaryText = stats.nextcloud?.system?.memcacheDistributed ?? "N/A"
        }

        content.textProperties.color = .themeColor
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.selectionStyle = .none
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

        var content = cell.defaultContentConfiguration()

        switch cellRow {
        case .space:
            content.text = "Free Space"
            content.secondaryText = freeSpace()
        case .files:
            content.text = "Number of Files"
            content.secondaryText = numberOfFiles()
        }

        content.textProperties.color = .themeColor
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.selectionStyle = .none
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

        var content = cell.defaultContentConfiguration()

        switch cellRow {
        case .last5: content.text = "Last 5 Minutes"
        case .lastHour: content.text = "Last Hour"
        case .lastDay: content.text = "Last Day"
        case .total: content.text = "Total Users"
        }

        content.textProperties.color = .themeColor
        content.secondaryText = activityValue(for: cellRow)
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.selectionStyle = .none
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
}
