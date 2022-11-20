//
//  NextStatsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/21/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

/// Facilitates the fetching and parsing of OCS objects into NextStat objects
class NextStatsDataManager: NSObject {
    /// Returns the shared `StatisticsDataManager` instance
    public static let shared = NextStatsDataManager()

    private let dataManager = DataManager.shared

    var nextStats = NextStats()
    weak var delegate: NextDataManagerDelegate?
    weak var errorHandler: ErrorHandler?

    var server: NextServer? {
        didSet {
            if server != nil {
                fetchData(for: server!)
            }
        }
    }

    private func fetchData(for server: NextServer) {
        // Notify the delegate of the class state
        delegate?.stateDidChange(.fetchingData)

        // Prepare the URL Configuration
        var urlString = server.URLString
        let config = URLSessionConfiguration.default
        let headers = ["Authorization": server.authenticationString()]

        config.httpAdditionalHeaders = headers

        dataManager.getServerStatisticsDataWithSuccess(urlString: urlString, config: config) { data, error in

            guard error == nil else {
                self.errorHandler?.handle(error: error!)
                return
            }

            guard let capturedData = data else {
                self.errorHandler?.handle(error: .invalidData)
                return
            }

            DispatchQueue.main.async {
                self.decode(capturedData)
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
            let cpuStringArray = cpuUsageArray.map { String(format: "%.2f", $0) }
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
            systemData.append(usage(free: freeSwapInBytes, total: totalSwapInBytes))

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
        let serverData = [server.webserver ?? "N/A",
                          server.php?.version ?? "N/A",
                          server.database?.type ?? "N/A",
                          server.database?.version ?? "N/A"]

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
    private func usagePercent(free: Int, total: Int) -> String {
        let freeDouble = Double(free)
        let totalDouble = Double(total)

        // Make suren the numbers are not .NaN or .infinite
        guard freeDouble.isNormal, totalDouble.isNormal else { return "N/A" }

        // Calculate the percentate
        let percent = calculatePercent(freeMemory: freeDouble, totalMemory: totalDouble)

        // Check again
        guard percent.isNormal else { return "N/A" }

        return String(format: "%.2f", percent).appending("%")
    }

    private func usage(free: Int, total: Int) -> String {
        let freeDouble = Double(free)
        let totalDouble = Double(total)

        // Make suren the numbers are not .NaN or .infinite
        guard freeDouble.isNormal, totalDouble.isNormal else { return "N/A" }

        // Convert them to gigabytes
        let memoryUsedInGB = Units(kilobytes: totalDouble - freeDouble).gigabytes
        let totalMemoryInGB = Units(kilobytes: totalDouble).gigabytes

        // Change to Strings
        let memoryUsedString = String(format: "%.2f", memoryUsedInGB)
        let totalMemoryString = String(format: "%.2f", totalMemoryInGB)

        return "\(memoryUsedString)/\(totalMemoryString) GB"
    }

    private func calculateMemoryUsed(freeMemory: Double, totalMemory: Double) -> Double {
        return totalMemory - freeMemory
    }

    private func calculatePercent(freeMemory: Double, totalMemory: Double) -> Double {
        let totalUsed = totalMemory - freeMemory

        return (totalUsed / totalMemory) * 100
    }
}
