//
//  StatisticsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

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
                self.parseServerStatisticsJSON(from: data)
            }
        }
    }

    /// Parses data into ServerStats Model
    func parseServerStatisticsJSON(from data: Data) {
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
        // Split statistics into variables
        // Certain Nextcloud configurations can cause unexpected or missing data
        guard let system = statistics.ocs?.data?.nextcloud,
              let server = statistics.ocs?.data?.server,
              let users = statistics.ocs?.data?.activeUsers
        else {
            delegate?.failedToUpdateData(error: .missingData)
            return
        }

        // Update System Section
        // Memory data is especially finicky with certain Nextcloud installations,
        // values may be String or Int,
        // tread with caution
        var memoryUsage = "N/A"
        var memory = "N/A"
        var swapUsage = "N/A"
        var swap = "N/A"
        var cpu = "N/A"

        // Make sure memory values are present
        if let freeMemoryBytes = system.system?.memFree?.intValue {
            if let totalMemoryBytes = system.system?.memTotal?.intValue {
                // Convert values to Doubles, then check that they are not Infinite or NaN
                let freeMemoryBytesDouble = Double(freeMemoryBytes)
                let totalMemoryBytesDouble = Double(totalMemoryBytes)
                if !freeMemoryBytesDouble.isInfinite && !freeMemoryBytesDouble.isNaN {
                    if !totalMemoryBytesDouble.isInfinite && !totalMemoryBytesDouble.isNaN {
                        // Calculate memoryUsage and totalMemory
                        let calculatedMemoryUsage = calculateMemoryUsagePercent(freeMemory: freeMemoryBytesDouble, totalMemory: totalMemoryBytesDouble)

                        // One final check, this is where the issue seems to lie
                        if !calculatedMemoryUsage.isInfinite && !calculatedMemoryUsage.isNaN {
                            let memoryUsageInt = Int(calculatedMemoryUsage)

                            memoryUsage = String("\(memoryUsageInt)%")

                            let memoryUsed = totalMemoryBytesDouble - freeMemoryBytesDouble
                            let memoryUsedInGigabytes = bytesToGigabytes(bytes: memoryUsed)
                            let totalMemoryInGigabytes = bytesToGigabytes(bytes: totalMemoryBytesDouble)
                            let memoryUsedString = String(format: "%.2f", memoryUsedInGigabytes)
                            let totalMemoryString = String(format: "%.2f", totalMemoryInGigabytes)

                            memory = "\(memoryUsedString)/\(totalMemoryString) GB"
                        }
                    }
                }

            }
        }

        // Make sure swap values are present
        if let freeSwapBytes = system.system?.swapFree?.intValue {
            if let totalSwapBytes = system.system?.swapTotal?.intValue {
                // Convert values to Doubles, then check that they are not Infinite or NaN
                let freeSwapBytesDouble = Double(freeSwapBytes)
                let totalSwapBytesDouble = Double(totalSwapBytes)
                if !freeSwapBytesDouble.isInfinite && !freeSwapBytesDouble.isNaN {
                    if !totalSwapBytesDouble.isInfinite && !totalSwapBytesDouble.isNaN {
                        // Calculate swapUsage and totalSwap
                        let calculatedSwapUsage = calculateMemoryUsagePercent(freeMemory: freeSwapBytesDouble, totalMemory: totalSwapBytesDouble)

                        // One final check, this is where the issue seems to lie
                        if !calculatedSwapUsage.isInfinite && !calculatedSwapUsage.isNaN {
                            let swapUsageInt = Int(calculatedSwapUsage)

                            swapUsage = String("\(swapUsageInt)%")

                            let swapUsed = totalSwapBytesDouble - freeSwapBytesDouble
                            let swapUsedInGigabytes = bytesToGigabytes(bytes: swapUsed)
                            let totalSwapInGigabytes = bytesToGigabytes(bytes: totalSwapBytesDouble)
                            let swapUsedString = String(format: "%.2f", swapUsedInGigabytes)
                            let totalSwapString = String(format: "%.2f", totalSwapInGigabytes)

                            swap = "\(swapUsedString)/\(totalSwapString) GB"
                        }
                    }
                }

            }
        }

        // Convert CPU array to string
        if let cpuUsageArray = system.system?.cpuload {
            // CPU array SHOULD only have three values
            if cpuUsageArray.count == 3 {
                let cpuString = "\(cpuUsageArray[0]), \(cpuUsageArray[1]), \(cpuUsageArray[2])"

                cpu = cpuString
            }
        }

        nextStat.setSystemData(for: .version, to: system.system?.version ?? "N/A")
        nextStat.setSystemData(for: .cpuLoad, to: cpu)
        nextStat.setSystemData(for: .memoryUsage, to: memoryUsage)
        nextStat.setSystemData(for: .memory, to: memory)
        nextStat.setSystemData(for: .swapUsage, to: swapUsage)
        nextStat.setSystemData(for: .swap, to: swap)
        nextStat.setSystemData(for: .localCache, to: system.system?.memcacheLocal ?? "N/A")
        nextStat.setSystemData(for: .distributedCache, to: system.system?.memcacheDistributed ?? "N/A")

        // Update Storage Section
        var freeSpace = "N/A"
        var numberOfFiles = "N/A"

        if let possibleFreeSpace = system.system?.freespace {
            let freeSpaceDouble = Double(possibleFreeSpace)
            if !freeSpaceDouble.isNaN && !freeSpaceDouble.isInfinite {
                let freeSpaceGigabytes = freeSpaceDouble / 1073741824.0
                let freeSpaceString = String(format: "%.2f", freeSpaceGigabytes)

                freeSpace = freeSpaceString + " GB"
            }
        }

        if let possibleNumberOffiles = system.storage?.numFiles {
            let numberOfFilesString = String(possibleNumberOffiles)

            numberOfFiles = numberOfFilesString
        }

        nextStat.setStorageData(for: .freeSpace, to: freeSpace)
        nextStat.setStorageData(for: .numberOfFiles, to: numberOfFiles)

        nextStat.setServerData(for: .webServer, to: server.webserver ?? "N/A")
        nextStat.setServerData(for: .phpVersion, to: server.php?.version ?? "N/A")
        nextStat.setServerData(for: .database, to: server.database?.type ?? "N/A")
        nextStat.setServerData(for: .databaseVersion, to: server.database?.version ?? "N/A")

        // Update Active Users Section
        var last5 = "N/A"
        var lastHour = "N/A"
        var lastDay = "N/A"
        var total = "N/A"

        if let possibleLast5 = users.last5Minutes {
            last5 = String(possibleLast5)
        }

        if let possibleLastHour = users.last1Hour {
            lastHour = String(possibleLastHour)
        }

        if let possibleLastDay = users.last24Hours {
            lastDay = String(possibleLastDay)
        }

        if let possibleTotal = system.storage?.numUsers {
            total = String(possibleTotal)
        }

        nextStat.setActiveUserData(for: .last5Minutes, to: last5)
        nextStat.setActiveUserData(for: .lastHour, to: lastHour)
        nextStat.setActiveUserData(for: .lastDay, to: lastDay)
        nextStat.setActiveUserData(for: .total, to: total)

        DispatchQueue.main.async {
            self.delegate?.dataUpdated()
        }
    }

    private func bytesToGigabytes(bytes: Double) -> Double {
        return bytes / 1048576.0
    }

    private func calculateMemoryUsed(freeMemory: Double, totalMemory: Double) -> Double {
        let totalUsed = totalMemory - freeMemory
        let totalUsedInGigabytes = totalUsed / 1048576.0

        return totalUsedInGigabytes
    }

    private func calculateMemoryUsagePercent(freeMemory: Double, totalMemory: Double) -> Double {
        let totalUsed = totalMemory - freeMemory
        let usagePercentage = (totalUsed / totalMemory) * 100

        return usagePercentage
    }
}

/// StatisticsDataManager TableView Data Functions
extension StatisticsDataManager {
    func sections() -> Int {
        return Sections.allCases.count
    }

    func sectionLabel(for section: Int) -> String {
        return nextStat.section(section)
    }

    func rows(in section: Int) -> Int {
        switch section {
        case 0: return SystemIndex.allCases.count
        case 1: return StorageIndex.allCases.count
        case 2: return ServerIndex.allCases.count
        case 3: return ActiveUsersIndex.allCases.count
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
