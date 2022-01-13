//
//  NextStatsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/21/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

/// Facilitates the fetching and parsing of OCS objects into NextStat objects
class NextStatsDataManager: NSObject {
    /// Returns the shared `StatisticsDataManager` instance
    public static let shared = NextStatsDataManager()

    private let networkController = NetworkController.shared
    var nextStats = Stats()
    weak var delegate: NextDataManagerDelegate?

    var server: NextServer? {
        didSet {
            if server != nil {
                fetchData(for: server!)
            } else {
                delegate?.stateDidChange(.serverNotSet)
            }
        }
    }

    private func fetchData(for server: NextServer) {
        // Notify the delegate of the class state
        delegate?.stateDidChange(.fetchingData)

        // Prepare URL Config
        let url = URL(string: server.URLString)!
        let config = networkController.configuration(authorizaton: server.authenticationString())
        let request = networkController.request(url: url, with: .statEndpoint)

        // Fetch data from server using networkController
        networkController.fetchData(with: request, using: config) { (result: Result<Data, FetchError>) in
            switch result {
            case .success(let data):
                // Here we parse our data
                print("piss")
            case .failure(let fetchError):
                // Notify the delate of the error
                DispatchQueue.main.async {
                    self.delegate?.stateDidChange(.failed(.networkError(fetchError)))
                }
            }
        }
    }

    private func format(statistics: ServerStats) {

    }

    func reload() {
        guard let server = server else { return }
        fetchData(for: server)
    }

    /// Arm the data manager with a server
    func armWith(server: NextServer) {
        // We do the arming here
    }
}
