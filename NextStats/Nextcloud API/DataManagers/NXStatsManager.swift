//
//  NextStatsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/21/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

/// Facilitates the fetching and parsing of OCS objects into NextStat objects
final class NXStatsManager: NSObject {
    /// Returns the shared `StatisticsDataManager` instance
    public static let shared = NXStatsManager()

    private let service = NextcloudService.shared

    var stats: DataClass?
    weak var delegate: NXDataManagerDelegate?
    weak var errorHandler: ErrorHandling?

    var server: NextServer? {
        didSet {
            if server != nil {
                requestStatistics(for: server!)
            }
        }
    }

    private var versionNumber: String? {
        return stats?.nextcloud?.system?.version
    }

    private func requestStatistics(for server: NextServer) {
        delegate?.stateDidChange(.fetchingData)

        Task {
            do {
                let object = try await service.fetchStatistics(for: server)
                await check(object)
            } catch {
                guard let error = error as? APIManagerError else {
                    errorHandler?.handleError(.somethingWentWrong(error: error))
                    return
                }
                errorHandler?.handleError(error)
            }
        }
    }

    @MainActor private func check(_ object: ServerStats) {
        guard let data = object.ocs?.data
        else {
            errorHandler?.handleError(.dataEmpty)
            return
        }

        stats = data
        buildTableData()
    }

    func reload() {
        guard let server = server else { return }
        requestStatistics(for: server)
    }

    /// Set the server value
    func set(server: NextServer) {
        self.server = server
    }

    // MARK: - Formatting
    private func buildTableData() {
        guard let stats = stats else { return }
        // Build System
        let systemSection = TableSection(
            title: StatsSection.system.header(
                version: versionNumber
            ),
            rows: systemSection(for: stats)
        )

        // Build Memory
        let memorySection = TableSection(
            title: StatsSection.memory.header(version: nil),
            rows: memorySection(for: stats)
        )

        // Build Storage
        let storageSection = TableSection(
            title: StatsSection.storage.header(version: nil),
            rows: storageSection(for: stats)
        )

        // Build Activity
        let activitySection = TableSection(
            title: StatsSection.activity.header(version: nil),
            rows: activeUsersSection(for: stats)
        )

        // Send Data
        delegate?.stateDidChange(.dataCaptured([
            systemSection,
            memorySection,
            storageSection,
            activitySection
        ]))
    }

    private func systemSection(for stats: DataClass) -> [TableRow] {
        guard
            let server = stats.server,
            let system = stats.nextcloud?.system
        else { return emptyRows(for: SystemRow.self) }

        return SystemRow.allCases.map {
            TableRow(
                title: $0.title,
                secondaryText: $0.rowData(server: server, system: system)
            )
        }
    }

    private func memorySection(for stats: DataClass) -> [TableRow] {
        guard let system = stats.nextcloud?.system
        else { return emptyRows(for: MemoryRow.self) }
        return MemoryRow.allCases.map {
            TableRow(
                title: $0.title,
                progressData: $0.memoryCellData(system: system)
            )
        }
    }

    private func storageSection(for stats: DataClass) -> [TableRow] {
        guard
            let system = stats.nextcloud?.system,
            let storage = stats.nextcloud?.storage
        else { return emptyRows(for: StorageRow.self) }

        return StorageRow.allCases.map {
            TableRow(
                title: $0.title,
                secondaryText: $0.rowData(system: system, storage: storage)
            )
        }
    }

    private func activeUsersSection(for stats: DataClass) -> [TableRow] {
        guard
            let users = stats.activeUsers,
            let total = stats.nextcloud?.storage?.numUsers
        else { return emptyRows(for: ActivityRow.self) }

        return ActivityRow.allCases.map {
            TableRow(
                title: $0.title,
                secondaryText: $0.rowData(users: users, total: total)
            )
        }
    }

    // MARK: - Helper Methods

    private func emptyRows<T: TitledSection>(for _: T.Type) -> [TableRow] {
        return T.allCases.map {
            TableRow(title: $0.title, secondaryText: "N/A")
        }
    }
}
