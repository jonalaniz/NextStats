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
    var nextStats = NextStats()
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
                DispatchQueue.main.async {
                    self.decode(data)
                }
            case .failure(let fetchError):
                // Notify the delate of the error
                DispatchQueue.main.async {
                    self.delegate?.stateDidChange(.failed(.networkError(fetchError)))
                }
            }
        }
    }

    private func decode(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ServerStats.self, from: data)
            format(statistics: result)
        } catch {
            delegate?.stateDidChange(.failed(.unableToDecode))
        }
    }

    private func format(statistics: ServerStats) {
        guard let system = statistics.ocs?.data?.nextcloud?.system,
              let storage = statistics.ocs?.data?.nextcloud?.storage,
              let server = statistics.ocs?.data?.server,
              let users = statistics.ocs?.data?.activeUsers
        else {
            delegate?.stateDidChange(.failed(.missingData))
            return
        }

        parseSystem(system)
        parseStorage(storage, system: system)
        parseServer(server)
        parseUsers(users, storage: storage)

        delegate?.stateDidChange(.statsCaptured)
    }

    private func parseSystem(_ system: System) {
        var systemData = [String]()

        // Version Information
        systemData.append(system.version ?? "N/A")

        // CPU Information
        if let cpuUsageArray = system.cpuload {
            let cpuStringArray = cpuUsageArray.map { String($0) }
            systemData.append(cpuStringArray.joined(separator: ", "))
        } else {
            systemData.append("N/A")
        }

        // Check for Memory Values
        if let freeMemoryInBytes = system.memFree?.intValue,
           let totalMemoryInBytes = system.memTotal?.intValue {
            // Memory Usage (Percent)
            systemData.append(usagePercent(free: freeMemoryInBytes, total: totalMemoryInBytes))

            // Memory Usage
            systemData.append(usage(free: freeMemoryInBytes, total: totalMemoryInBytes))
        } else {
            systemData.append("N/A")
            systemData.append("N/A")
        }

        // Check for Swap Values
        if let freeSwapInBytes = system.swapFree?.intValue,
           let totalSwapInBytes = system.swapTotal?.intValue {
            // Swap Usage
            systemData.append(usagePercent(free: freeSwapInBytes, total: totalSwapInBytes))

            // Swap
            systemData.append(usagePercent(free: freeSwapInBytes, total: totalSwapInBytes))

        } else {
            systemData.append("N/A")
            systemData.append("N/A")
        }

        // Memcache.Local
        systemData.append(system.memcacheLocal ?? "N/A")

        // Memcache.Distributed
        systemData.append(system.memcacheDistributed ?? "N/A")

        // Set Our Data
        nextStats.set(systemData: systemData)

    }

    private func parseStorage(_ storage: Storage, system: System) {
        guard let freeSpace = system.freespace,
              let numberOfFiles = storage.numFiles
        else {
            nextStats.set(storageData: ["N/A", "N/A"])
            return
        }

        var storageData = [String]()

        let doubleFreeSpace = Double(freeSpace)
        if !doubleFreeSpace.isNaN && !doubleFreeSpace.isInfinite {
            storageData.append(Units(bytes: doubleFreeSpace).getReadableUnit())
        } else {
            storageData.append("N/A")
        }

        storageData.append(String(numberOfFiles))

        nextStats.set(storageData: storageData)
    }

    private func parseServer(_ server: Server) {
        let serverData = [server.webserver ?? "N/A"]

        nextStats.set(serverData: serverData)
    }

    private func parseUsers(_ users: ActiveUsers, storage: Storage) {
        guard let last5 = users.last5Minutes,
              let lastHour = users.last1Hour,
              let last24 = users.last24Hours,
              let total = storage.numUsers
        else {
            nextStats.set(userData: Array(repeating: "N/A", count: nextStats.rows(in: 3)))
            return
        }

        let activeUsers = [String(last5),
                           String(lastHour),
                           String(last24),
                           String(total)]

        nextStats.set(userData: activeUsers)
    }

    func reload() {
        guard let server = server else { return }
        fetchData(for: server)
    }

    /// Set the server value
    func set(server: NextServer) {
        self.server = server
    }
}

// Helper Functions
extension NextStatsDataManager {
    func usagePercent(free: Int, total: Int) -> String {
        let freeDouble = Double(free)
        let totalDouble = Double(total)

        // Make sure numbers are real
        if freeDouble.isNormal && totalDouble.isNormal {

            // Calculate the percentate
            let percent = calculatePercent(freeMemory: freeDouble, totalMemory: totalDouble)

            // Check if it is normal again
            if percent.isNormal {
                return String(format: "%.2f", percent).appending("%")
            } else {
                return "N/A"
            }
        } else {
            return "N/A"
        }
    }

    func usage(free: Int, total: Int) -> String {
        let freeDouble = Double(free)
        let totalDouble = Double(total)

        // Make sure numbers are real
        if freeDouble.isNormal && totalDouble.isNormal {
            // Convert them to gigabytes
            let memoryUsedInGB = Units(kilobytes: totalDouble - freeDouble).gigabytes
            let totalMemoryInGB = Units(kilobytes: totalDouble).gigabytes

            // Change to Strings
            let memoryUsedString = String(format: "%.2f", memoryUsedInGB)
            let totalMemoryString = String(format: "%.2f", totalMemoryInGB)

            return "\(memoryUsedString)/\(totalMemoryString) GB"
        } else {
            return "N/A"
        }
    }

    private func calculateMemoryUsed(freeMemory: Double, totalMemory: Double) -> Double {
        return totalMemory - freeMemory
    }

    private func calculatePercent(freeMemory: Double, totalMemory: Double) -> Double {
        let totalUsed = totalMemory - freeMemory

        return (totalUsed / totalMemory) * 100
    }
}
