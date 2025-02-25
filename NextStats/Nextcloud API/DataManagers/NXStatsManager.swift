//
//  NextStatsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/21/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

/// Facilitates the fetching and parsing of OCS objects into NextStat objects
final class NXStatsManager: NSObject, NXStatsDataProvider {
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
            errorHandler?.handleError(.serializaitonFailed)
            return
        }

        stats = data
        delegate?.stateDidChange(.dataCaptured)
    }

    func reload() {
        guard let server = server else { return }
        requestStatistics(for: server)
    }

    /// Set the server value
    func set(server: NextServer) {
        self.server = server
    }
}
