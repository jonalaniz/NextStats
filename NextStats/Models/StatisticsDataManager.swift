//
//  StatisticsDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

// Server Data Label Enums
enum Sections: Int {
    case system
    case storage
    case server
    case activeUsers
}

enum SystemIndex: Int {
    case version
    case cpuLoad
    case memoryUsage
    case memory
    case swapUsage
    case swap
    case localCache
    case distributedCache
}

enum StorageIndex: Int {
    case freeSpace
    case numberOfFiles
}

enum ServerIndex: Int {
    case webServer
    case phpVersion
    case database
    case databaseVersion
}

enum ActiveUsersIndex: Int {
    case last5Minutes
    case lastHour
    case lastDay
    case total
}

/// Facilitates the fetching and transormation of OCS objects
class StatisticsDataManager {
    /// Returns the singleton `StatisticsDataManager` instance
    public static let shared = StatisticsDataManager()

    private let networkController = NetworkController.shared

    weak var delegate: StatisticsDataManagerDelegate?

    var server: NextServer! {
        didSet {
            resetServerData()
            fetchData(for: server)
        }
    }

    // MARK: Labels
    private let sectionLabels = ["System", "Storage", "Server", "Active Users"]
    private let systemSectionLabels = ["Version", "CPU", "Memory Usage", "Memory", "Swap Usage", "Swap", "Local Cache", "Distributed Cache"]
    private let storageSectionLabels = ["Free Space", "Number of Files"]
    private let serverSectionLabels = ["Web Server", "PHP Version", "Database", "Database Version"]
    private let activeUsersSectionLabels = ["Last 5 Minutes", "Last Hour", "Last Day", "Total"]

    // MARK: Server Stats Data
    private var systemSectionData = [String]()
    private var storageSectionData = [String]()
    private var serverSectionData = [String]()
    private var activeUsersSectionData = [String]()

    init() {
        initializeSectionData()
    }
}

/// StatisticsDataManager Functions
extension StatisticsDataManager {

    // Initializes data before fetching
    private func initializeSectionData() {
        systemSectionData = Array(repeating: "...", count: systemSectionLabels.count)
        storageSectionData = Array(repeating: "...", count: storageSectionLabels.count)
        serverSectionData = Array(repeating: "...", count: serverSectionLabels.count)
        activeUsersSectionData = Array(repeating: "...", count: activeUsersSectionLabels.count)
    }

    private func resetServerData() {
        initializeSectionData()
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
            // TODO: This should show error that JSON was unable to be parsed, using generic error rn
            delegate?.failedToUpdateData(error: .unableToParseJSON)
        }
    }

    // Updates Server Stats Data with ServerStats struct
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

        systemSectionData[SystemIndex.version.rawValue] = system.system?.version ?? "N/A"
        systemSectionData[SystemIndex.cpuLoad.rawValue] = cpu
        systemSectionData[SystemIndex.memoryUsage.rawValue] = memoryUsage
        systemSectionData[SystemIndex.memory.rawValue] = memory
        systemSectionData[SystemIndex.swapUsage.rawValue] = swapUsage
        systemSectionData[SystemIndex.swap.rawValue] = swap
        systemSectionData[SystemIndex.localCache.rawValue] = system.system?.memcacheLocal ?? "N/A"
        systemSectionData[SystemIndex.distributedCache.rawValue] = system.system?.memcacheDistributed ?? "N/A"

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

        storageSectionData[StorageIndex.freeSpace.rawValue] = freeSpace
        storageSectionData[StorageIndex.numberOfFiles.rawValue] = numberOfFiles

        // Update Server Section
        serverSectionData[ServerIndex.webServer.rawValue] = server.webserver ?? "N/A"
        serverSectionData[ServerIndex.phpVersion.rawValue] = server.php?.version ?? "N/A"
        serverSectionData[ServerIndex.database.rawValue] = server.database?.type ?? "N/A"
        serverSectionData[ServerIndex.databaseVersion.rawValue] = server.database?.version ?? "N/A"

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

        activeUsersSectionData[ActiveUsersIndex.last5Minutes.rawValue] = last5
        activeUsersSectionData[ActiveUsersIndex.lastHour.rawValue] = lastHour
        activeUsersSectionData[ActiveUsersIndex.lastDay.rawValue] = lastDay
        activeUsersSectionData[ActiveUsersIndex.total.rawValue] = total

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
        return sectionLabels.count
    }

    func sectionLabel(for section: Int) -> String {
        return sectionLabels[section]
    }

    func rows(in section: Int) -> Int {
        switch section {
        case 0: return systemSectionLabels.count
        case 1: return storageSectionLabels.count
        case 2: return serverSectionLabels.count
        case 3: return activeUsersSectionLabels.count
        default: return 0
        }
    }

    func rowLabel(forRow row: Int, inSection section: Int) -> String {
        switch section {
        case 0: return systemSectionLabels[row]
        case 1: return storageSectionLabels[row]
        case 2: return serverSectionLabels[row]
        case 3: return activeUsersSectionLabels[row]
        default: return "N/A"
        }
    }

    func rowData(forRow row: Int, inSection section: Int) -> String {
        switch section {
        case 0:
            return systemSectionData[row]
        case 1:
            return storageSectionData[row]
        case 2:
            return serverSectionData[row]
        case 3:
            return activeUsersSectionData[row]
        default:
            return "N/A"
        }
    }
}
