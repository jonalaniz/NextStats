//
//  StatisticsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz
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
                let calculatedMemoryUsage = calculateMemoryUsage(freeMemory: freeMemoryBytesDouble, totalMemory: totalMemoryBytesDouble)

                // One final check, this is where the issue seems to lie
                if !calculatedMemoryUsage.isInfinite && !calculatedMemoryUsage.isNaN {
                    memoryUsage = String(format: "%.2f", calculatedMemoryUsage).appending("%")

                    let memoryUsedInGigabytes = Units(kilobytes: totalMemoryBytesDouble - freeMemoryBytesDouble).gigabytes
                    let totalMemoryInGigabytes = Units(kilobytes: totalMemoryBytesDouble).gigabytes
                    let memoryUsedString = String(format: "%.2f", memoryUsedInGigabytes)
                    let totalMemoryString = String(format: "%.2f", totalMemoryInGigabytes)

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
                let calculatedSwapUsage = calculateMemoryUsage(freeMemory: freeSwapBytesDouble, totalMemory: totalSwapBytesDouble)

                // One final check, this is where the issue seems to lie
                if !calculatedSwapUsage.isInfinite && !calculatedSwapUsage.isNaN {
                    swapUsage = String(format: "%.2f", calculatedSwapUsage).appending("%")

                    let swapUsedInGigabytes = Units(kilobytes: totalSwapBytesDouble - freeSwapBytesDouble).gigabytes
                    let totalSwapInGigabytes = Units(kilobytes: totalSwapBytesDouble).gigabytes
                    let swapUsedString = String(format: "%.2f", swapUsedInGigabytes)
                    let totalSwapString = String(format: "%.2f", totalSwapInGigabytes)

                    swap = "\(swapUsedString)/\(totalSwapString) GB"
                }
            }
        }

        // Convert CPU array to string
        if let cpuUsageArray = system.system?.cpuload {
            let cpuStringArray = cpuUsageArray.map { String($0) }

            cpu = cpuStringArray.joined(separator: ", ")
        }

        nextStat.setSystemData(for: .version, to: system.system?.version ?? "N/A")
        nextStat.setSystemData(for: .cpuLoad, to: cpu)
        nextStat.setSystemData(for: .memoryUsage, to: memoryUsage)
        nextStat.setSystemData(for: .memory, to: memory)
        nextStat.setSystemData(for: .swapUsage, to: swapUsage)
        nextStat.setSystemData(for: .swap, to: swap)
        nextStat.setSystemData(for: .localCache, to: system.system?.memcacheLocal ?? "N/A")
        nextStat.setSystemData(for: .distributedCache, to: system.system?.memcacheDistributed ?? "N/A")

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

        nextStat.setStorageData(for: .freeSpace, to: freeSpace)
        nextStat.setStorageData(for: .numberOfFiles, to: numberOfFiles)

        // MARK: - Server
        nextStat.setServerData(for: .webServer, to: server.webserver ?? "N/A")
        nextStat.setServerData(for: .phpVersion, to: server.php?.version ?? "N/A")
        nextStat.setServerData(for: .database, to: server.database?.type ?? "N/A")
        nextStat.setServerData(for: .databaseVersion, to: server.database?.version ?? "N/A")

        // MARK: - Active Users
        if let possibleLast5 = users.last5Minutes,
           let possibleLastHour = users.last1Hour,
           let possibleLastDay = users.last24Hours,
           let possibleTotal = system.storage?.numUsers {
            nextStat.setActiveUserData(for: .last5Minutes, to: String(possibleLast5))
            nextStat.setActiveUserData(for: .lastHour, to: String(possibleLastHour))
            nextStat.setActiveUserData(for: .lastDay, to: String(possibleLastDay))
            nextStat.setActiveUserData(for: .total, to: String(possibleTotal))
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
