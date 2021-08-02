//
//  StatisticsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.

import Foundation

/// Facilitates the fetching and transormation of OCS objects into NextStat objects.
class StatisticsDataManager {
    /// Returns the singleton `StatisticsDataManager` instance
    public static let shared = StatisticsDataManager()

    private let networkController = NetworkController.shared
    private var nextStat = NextStat()
    weak var delegate: StatisticsDataManagerDelegate?

    var server: NextServer! {
        didSet {
            resetServerData()
            fetchData(for: server)
        }
    }

    func reload() {
        fetchData(for: server)
    }

    private func resetServerData() {
        nextStat.initializeSectionData()
        delegate?.dataUpdated()
    }

    private func fetchData(for server: NextServer) {
        // Notify our delegate
        delegate?.willBeginFetchingData()

        // Prepare URL Configuration
        let url = URL(string: server.URLString)!
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": server.authenticationString()]
        let request = URLRequest(url: url)

        // Fetch data from server using networkController
        networkController.fetchData(with: request, using: config) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(let fetchError):
                // Notify the delegate of our error
                self.delegate?.failedToFetchData(error: fetchError)
            case .success(let data):
                // Update our statistics with the fetched data
                self.decodeServerStats(from: data)
            }
        }
    }

    /// Decodes JSON data into ServerStats model
    func decodeServerStats(from data: Data) {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ServerStats.self, from: data)
            updateData(with: result)
        } catch {
            delegate?.failedToUpdateData(error: .unableToParseJSON)
        }
    }

    /// Updates Server Stats Data with ServerStats struct
    private func updateData(with statistics: ServerStats) {
        // Split statistics into variables, if data is missing fail and return
        guard let system = statistics.ocs?.data?.nextcloud,
              let server = statistics.ocs?.data?.server,
              let users = statistics.ocs?.data?.activeUsers
        else {
            delegate?.failedToUpdateData(error: .missingData)
            return
        }

        // MARK: - System
        var memoryUsage = "N/A"
        var memory = "N/A"
        var swapUsage = "N/A"
        var swap = "N/A"
        var cpu = "N/A"

        // Make sure memory values are present
        if let freeMemoryBytes = system.system?.memFree?.intValue,
           let totalMemoryBytes = system.system?.memTotal?.intValue {
            // Convert values to Doubles, then check that they are not Infinite or NaN
            let freeMemoryBytesDouble = Double(freeMemoryBytes)
            let totalMemoryBytesDouble = Double(totalMemoryBytes)
            if !freeMemoryBytesDouble.isInfinite && !freeMemoryBytesDouble.isNaN
                && !totalMemoryBytesDouble.isInfinite && !totalMemoryBytesDouble.isNaN {
                // Calculate memoryUsage and totalMemory
                let calculatedMemoryUsage = calculateMemoryUsage(freeMemory: freeMemoryBytesDouble,
                                                                 totalMemory: totalMemoryBytesDouble)

                // One final check, this is where the issue seems to lie
                if !calculatedMemoryUsage.isInfinite && !calculatedMemoryUsage.isNaN {
                    memoryUsage = String(format: "%.2f", calculatedMemoryUsage).appending("%")

                    let memoryUsedInGB = Units(kilobytes: totalMemoryBytesDouble - freeMemoryBytesDouble).gigabytes
                    let totalMemoryInGB = Units(kilobytes: totalMemoryBytesDouble).gigabytes
                    let memoryUsedString = String(format: "%.2f", memoryUsedInGB)
                    let totalMemoryString = String(format: "%.2f", totalMemoryInGB)

                    memory = "\(memoryUsedString)/\(totalMemoryString) GB"
                }
            }
        }

        // Make sure swap values are present
        if let freeSwapBytes = system.system?.swapFree?.intValue,
           let totalSwapBytes = system.system?.swapTotal?.intValue {
            // Convert values to Doubles, then check that they are not Infinite or NaN
            let freeSwapBytesDouble = Double(freeSwapBytes)
            let totalSwapBytesDouble = Double(totalSwapBytes)
            if !freeSwapBytesDouble.isInfinite && !freeSwapBytesDouble.isNaN
                && !totalSwapBytesDouble.isInfinite && !totalSwapBytesDouble.isNaN {
                // Calculate swapUsage and totalSwap
                let calculatedSwapUsage = calculateMemoryUsage(freeMemory: freeSwapBytesDouble,
                                                               totalMemory: totalSwapBytesDouble)

                // One final check, this is where the issue seems to lie
                if !calculatedSwapUsage.isInfinite && !calculatedSwapUsage.isNaN {
                    swapUsage = String(format: "%.2f", calculatedSwapUsage).appending("%")

                    let swapUsedInGB = Units(kilobytes: totalSwapBytesDouble - freeSwapBytesDouble).gigabytes
                    let totalSwapInGB = Units(kilobytes: totalSwapBytesDouble).gigabytes
                    let swapUsedString = String(format: "%.2f", swapUsedInGB)
                    let totalSwapString = String(format: "%.2f", totalSwapInGB)

                    swap = "\(swapUsedString)/\(totalSwapString) GB"
                }
            }
        }

        // Convert CPU array to string
        if let cpuUsageArray = system.system?.cpuload {
            let cpuStringArray = cpuUsageArray.map { String($0) }

            cpu = cpuStringArray.joined(separator: ", ")
        }

        nextStat.setSystemData(version: system.system?.version ?? "N/A",
                               cpuLoad: cpu,
                               memoryUsage: memoryUsage,
                               memory: memory,
                               swapUsage: swapUsage,
                               swap: swap,
                               localCache: system.system?.memcacheLocal ?? "N/A",
                               distributedCache: system.system?.memcacheDistributed ?? "N/A")

        // MARK: - Storage
        var freeSpace = "N/A"
        var numberOfFiles = "N/A"

        if let possibleFreeSpace = system.system?.freespace {
            let freeSpaceDouble = Double(possibleFreeSpace)
            if !freeSpaceDouble.isNaN && !freeSpaceDouble.isInfinite {
                freeSpace = Units(bytes: freeSpaceDouble).getReadableUnit()
            }
        }

        if let possibleNumberOfFiles = system.storage?.numFiles {
            numberOfFiles = String(possibleNumberOfFiles)
        }

        nextStat.setStorageData(freeSpace: freeSpace, numberOfFiles: numberOfFiles)

        // MARK: - Server
        nextStat.setServerData(webServer: server.webserver ?? "N/A",
                               phpVersion: server.php?.version ?? "N/A",
                               database: server.database?.type ?? "N/A",
                               databaseVersion: server.database?.version ?? "N/A")

        // MARK: - Active Users
        if let possibleLast5 = users.last5Minutes,
           let possibleLastHour = users.last1Hour,
           let possibleLastDay = users.last24Hours,
           let possibleTotal = system.storage?.numUsers {
            nextStat.setActiveUserData(last5Minutes: String(possibleLast5),
                                       lastHour: String(possibleLastHour),
                                       lastDay: String(possibleLastDay),
                                       total: String(possibleTotal))
        } else {
            nextStat.activeUserDataNotFound()
        }

        DispatchQueue.main.async {
            self.delegate?.dataUpdated()
        }
    }

    private func calculateMemoryUsed(freeMemory: Double, totalMemory: Double) -> Double {
        return totalMemory - freeMemory
    }

    private func calculateMemoryUsage(freeMemory: Double, totalMemory: Double) -> Double {
        let totalUsed = totalMemory - freeMemory

        return (totalUsed / totalMemory) * 100
    }
}

/// StatisticsDataManager TableView Data Functions
extension StatisticsDataManager {
    func sections() -> Int {
        return nextStat.sectionLabels.count
    }

    func sectionLabel(for section: Int) -> String {
        return nextStat.section(section)
    }

    func rows(in section: Int) -> Int {
        switch section {
        case 0: return nextStat.systemSectionLabels.count
        case 1: return nextStat.storageSectionLabels.count
        case 2: return nextStat.serverSectionLabels.count
        case 3: return nextStat.activeUsersSectionLabels.count
        default: return 0
        }
    }

    func rowLabel(forRow row: Int, inSection section: Int) -> String {
        return nextStat.label(forRow: row, inSection: section)
    }

    func rowData(forRow row: Int, inSection section: Int) -> String {
        return nextStat.data(forRow: row, inSection: section)
    }
}
