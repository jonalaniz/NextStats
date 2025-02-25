//
//  StatsDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/19/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

protocol NXStatsDataProvider {
    var stats: DataClass? { get }
}

class StatsDataSource: NSObject, UITableViewDataSource {
    let dataProvider: NXStatsDataProvider

    init(dataProvider: NXStatsDataProvider) {
        self.dataProvider = dataProvider
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
        return StatsSection(rawValue: section)?.header(version: versionNumber)
    }

    private func systemCell(row: Int) -> UITableViewCell {
        guard
            let type = SystemRow(rawValue: row),
            let server = dataProvider.stats?.server,
            let system = dataProvider.stats?.nextcloud?.system
        else { return UITableViewCell() }

        let secondaryText: String = {
            switch type {
            case .cpu: return formattedCPULoad
            case .webServer: return server.webserver ?? "N/A"
            case .phpVersion: return server.php?.version ?? "N/A"
            case .databaseVersion: return formattedDatabaseVersion
            case .databaseSize: return formattedDatabaseSize
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
            case .ram: return (ram.0, ram.1, .memory)
            case .swap: return (swap.0, swap.1, .swap)
            }
        }()

        return ProgressCell(free: free ?? 0, total: total ?? 0, type: type)
    }

    private func storageCell(row: Int) -> UITableViewCell {
        guard let type = StorageRow(rawValue: row)
        else { return UITableViewCell() }

        let secondaryText = type == .space ? formattedFreeSpace : formattedFileCount

        return configureCell(text: type.title, secondaryText: secondaryText)
    }

    private func activityCell(row: Int) -> UITableViewCell {
        guard let type = ActivityRow(rawValue: row)
        else { return UITableViewCell() }

        return configureCell(text: type.title,
                             secondaryText: activeUsers(for: type))
    }

    private var versionNumber: String? {
        return dataProvider.stats?.nextcloud?.system?.version
    }

    private var formattedCPULoad: String {
        guard let usageArray = dataProvider.stats?.nextcloud?.system?.cpuload
        else { return "N/A "}

        return usageArray.map { String(format: "%.2f", $0) }
            .joined(separator: ", ")
    }

    private var formattedDatabaseVersion: String {
        guard let database = dataProvider.stats?.server?.database
        else { return "N/A" }
        return "\(database.type ?? "N/A") \(database.version ?? "")"
    }

    private var formattedDatabaseSize: String {
        guard let size = dataProvider.stats?.server?.database?.size
        else { return "N/A" }

        switch size {
        case .string(let string):
            guard let intValue = Int(string) else { return "N/A" }
            return Units(bytes: Double(intValue)).getReadableUnit()
        case .int(let int):
            return Units(bytes: Double(int)).getReadableUnit()
        }
    }

    private var ram: (Int?, Int?) {
        let free = dataProvider.stats?.nextcloud?.system?.memFree?.intValue
        let total = dataProvider.stats?.nextcloud?.system?.memTotal?.intValue
        return (free, total)
    }

    private var swap: (Int?, Int?) {
        let free = dataProvider.stats?.nextcloud?.system?.swapFree?.intValue
        let total = dataProvider.stats?.nextcloud?.system?.swapTotal?.intValue
        return (free, total)
    }

    private var formattedFreeSpace: String {
        guard let freeSpace = dataProvider.stats?.nextcloud?.system?.freespace
        else { return "N/A" }

        let bytes = Double(freeSpace)
        return bytes.isNaN || bytes.isInfinite ? "N/A" : Units(bytes: bytes).getReadableUnit()
    }

    private var formattedFileCount: String {
        guard let number = dataProvider.stats?.nextcloud?.storage?.numFiles
        else { return "N/A" }

        return String(number)
    }

    private func activeUsers(for row: ActivityRow) -> String {
        guard
            let last5 = dataProvider.stats?.activeUsers?.last5Minutes,
            let lastHour = dataProvider.stats?.activeUsers?.last1Hour,
            let lastDay = dataProvider.stats?.activeUsers?.last24Hours,
            let total = dataProvider.stats?.nextcloud?.storage?.numUsers
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
                                 secondaryText: secondaryText,
                                 isInteractive: false)
    }
}
