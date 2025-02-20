//
//  StatsDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/19/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class StatsDataSource: NSObject, UITableViewDataSource {
    let dataManager: NXStatsManager

    init(dataManager: NXStatsManager) {
        self.dataManager = dataManager
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return StatsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StatsSection(rawValue: section)?.rows ?? 0
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
        return StatsSection(rawValue: section)?.header(version: versionNumber())
    }

    private func systemCell(row: Int) -> UITableViewCell {
        guard
            let type = SystemRow(rawValue: row),
            let system = dataManager.stats.nextcloud?.system
        else { return UITableViewCell() }

        let secondaryText: String = {
            switch type {
            case .cpu: return cpuLoadAverages()
            case .webServer: return dataManager.stats.server?.webserver ?? "N/A"
            case .phpVersion: return dataManager.stats.server?.php?.version ?? "N/A"
            case .databaseVersion: return databaseVersion()
            case .databaseSize: return databaseSize()
            case .localCache: return system.memcacheLocal ?? "N/A"
            case .distributedCache: return system.memcacheDistributed ?? "N/A"
            }
        }()

        return configureCell(text: type.title, secondaryText: secondaryText)
    }

    private func memoryCell(row: Int) -> ProgressCell {
        guard let cellRow = MemoryRow(rawValue: row)
        else { return ProgressCell(free: 0, total: 0, type: .memory) }

        let (free, total, type): (Int?, Int?, ProgressCellIcon) = {
            switch cellRow {
            case .ram: return (ram().0, ram().1, .memory)
            case .swap: return (swap().0, swap().1, .swap)
            }
        }()

        return ProgressCell(free: free ?? 0, total: total ?? 0, type: type)
    }

    private func storageCell(row: Int) -> UITableViewCell {
        guard let type = StorageRow(rawValue: row)
        else { return UITableViewCell() }

        let secondaryText = type == .space ? freeSpace() : numberOfFiles()

        return configureCell(text: type.title, secondaryText: secondaryText)
    }

    private func activityCell(row: Int) -> UITableViewCell {
        guard let type = ActivityRow(rawValue: row)
        else { return UITableViewCell() }

        return configureCell(text: type.title,
                             secondaryText: activeUsers(for: type))
    }

    private func versionNumber() -> String? {
        return dataManager.stats.nextcloud?.system?.version
    }

    private func cpuLoadAverages() -> String {
        guard let usageArray = dataManager.stats.nextcloud?.system?.cpuload
        else { return "N/A "}

        return usageArray.map { String(format: "%.2f", $0) }
            .joined(separator: ", ")
    }

    private func databaseVersion() -> String {
        guard let database = dataManager.stats.server?.database
        else { return "N/A" }
        return "\(database.type ?? "N/A") \(database.version ?? "")"
    }

    private func databaseSize() -> String {
        guard let size = dataManager.stats.server?.database?.size
        else { return "N/A" }

        switch size {
        case .string(let string):
            guard let intValue = Int(string) else { return "N/A" }
            return Units(bytes: Double(intValue)).getReadableUnit()
        case .int(let int):
            return Units(bytes: Double(int)).getReadableUnit()
        }
    }

    private func ram() -> (Int?, Int?) {
        let free = dataManager.stats.nextcloud?.system?.memFree?.intValue
        let total = dataManager.stats.nextcloud?.system?.memTotal?.intValue
        return (free, total)
    }

    private func swap() -> (Int?, Int?) {
        let free = dataManager.stats.nextcloud?.system?.swapFree?.intValue
        let total = dataManager.stats.nextcloud?.system?.swapTotal?.intValue
        return (free, total)
    }

    private func freeSpace() -> String {
        guard let freeSpace = dataManager.stats.nextcloud?.system?.freespace
        else { return "N/A" }

        let bytes = Double(freeSpace)
        return bytes.isNaN || bytes.isInfinite ? "N/A" : Units(bytes: bytes).getReadableUnit()
    }

    private func numberOfFiles() -> String {
        guard let number = dataManager.stats.nextcloud?.storage?.numFiles
        else { return "N/A" }

        return String(number)
    }

    private func activeUsers(for row: ActivityRow) -> String {
        guard
            let last5 = dataManager.stats.activeUsers?.last5Minutes,
            let lastHour = dataManager.stats.activeUsers?.last1Hour,
            let lastDay = dataManager.stats.activeUsers?.last24Hours,
            let total = dataManager.stats.nextcloud?.storage?.numUsers
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
