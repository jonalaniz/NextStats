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

    var container = StatisticsContainer()
    weak var delegate: NXDataManagerDelegate?
    weak var errorHandler: ErrorHandler?

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
                    errorHandler?.handle(error: .error(error.localizedDescription))
                    return
                }

                switch errorType {
                case .error(let description):
                    errorHandler?.handle(error: .error(description))
                case .invalidData:
                    errorHandler?.handle(error: .invalidData)
                case .invalidURL:
                    errorHandler?.handle(error: .invalidURL)
                case .missingResponse:
                    errorHandler?.handle(error: .missingResponse)
                case .unexpectedResponse(let response):
                    errorHandler?.handle(error: .unexpectedResponse(response))
                }
            }
        }
    }

    @MainActor private func format(statistics: ServerStats) {
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
        container.set(systemData: systemData)

    }

    private func parseStorage(_ storage: Storage, system: System) {
        guard let freeSpace = system.freespace,
              let numberOfFiles = storage.numFiles
        else {
            container.set(storageData: ["N/A", "N/A"])
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

        container.set(storageData: storageData)
    }

    private func parseServer(_ server: Server) {
        let serverData = [server.webserver ?? "N/A",
                          server.php?.version ?? "N/A",
                          server.database?.type ?? "N/A",
                          server.database?.version ?? "N/A"]

        container.set(serverData: serverData)
    }

    private func parseUsers(_ users: ActiveUsers, storage: Storage) {
        guard let last5 = users.last5Minutes,
              let lastHour = users.last1Hour,
              let last24 = users.last24Hours,
              let total = storage.numUsers
        else {
            container.set(userData: Array(repeating: "N/A", count: container.rows(in: 3)))
            return
        }

        let activeUsers = [String(last5),
                           String(lastHour),
                           String(last24),
                           String(total)]

        container.set(userData: activeUsers)
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

// Helper Functions
extension NXStatsManager {
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
