//
//  NextStatsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/21/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

/// Facilitates the fetching and parsing of OCS objects into NextStat objects
class NXStatsManager: NSObject {
    /// Returns the shared `StatisticsDataManager` instance
    public static let shared = NXStatsManager()

    private let networking = NetworkController.shared

    var stats: DataClass!
    weak var delegate: NXDataManagerDelegate?

    var server: NextServer? {
        didSet {
            if server != nil {
                requestStatistics(for: server!)
            }
        }
    }

    private func requestStatistics(for server: NextServer) {
        delegate?.stateDidChange(.fetchingData)

        let url = URL(string: server.URLString)!
        let authString = server.authenticationString()

        Task {
            do {
                let object = try await networking.fetchServerStatisticsData(url: url,
                                                                            authentication: authString)
                await format(statistics: object)
            } catch {
                guard let errorType = error as? FetchError else {
                    print("Timeout ERROR")
                    delegate?.stateDidChange(.failed(.networkError(.error(error.localizedDescription))))
                    return
                }

                switch errorType {
                case .error(let description):
                    delegate?.stateDidChange(.failed(.networkError(.error(description))))
                case .invalidData:
                    delegate?.stateDidChange(.failed(.networkError(.invalidData)))
                case .invalidURL:
                    delegate?.stateDidChange(.failed(.networkError(.invalidURL)))
                case .missingResponse:
                    delegate?.stateDidChange(.failed(.networkError(.missingResponse)))
                case .unexpectedResponse(let response):
                    delegate?.stateDidChange(.failed(.networkError(.unexpectedResponse(response))))
                }
            }
        }
    }

    @MainActor private func format(statistics: ServerStats) {
        guard let data = statistics.ocs?.data
        else {
            delegate?.stateDidChange(.failed(.missingData))
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
