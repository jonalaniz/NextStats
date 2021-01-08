//
//  ServerTableViewDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation

// MARK: - Enums

// Server Error Types + Return Strings
enum ServerError {
    case unauthorized
    case noResponse
    case jsonError
    case other
    
    var typeAndDescription: (title: String, description: String) {
        switch self {
        case .unauthorized:
            return("Unauthorized User", "You must have admin privilidges to view server stats.")
        case .noResponse:
            return("No Response", "The server cannot be reached, please check your internet connection or contact your adminstrator.")
        case .jsonError:
            return("JSON Error", "Could not parse JSON. Please check with your administrator.")
        case .other:
            return("Error", "Unspecified error, server cannot be reached")
        }
    }
}

// Server Data Label Enums
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

// MARK: - ServerTableViewDataManager
/**
  ServerTableViewDataManager facilitates transforming parts of the Monitor JSON Struct into data useable by UITableView
 */

struct ServerTableViewDataManager {
    // MARK: - Labels
    let sectionLabels = ["System", "Storage", "Server", "Active Users"]
    let systemSectionLabels = ["Version", "CPU", "Memory Usage", "Memory", "Swap Usage", "Swap", "Local Cache", "Distributed Cache"]
    let storageSectionLabels = ["Free Space", "Number of Files"]
    let serverSectionLabels = ["Web Server", "PHP Version", "Database", "Database Version"]
    let activeUsersSectionLabels = ["Last 5 Minutes", "Last Hour", "Last Day", "Total"]
    
    // MARK: - ServerData
    private var systemSectionData = [String]()
    private var storageSectionData = [String]()
    private var serverSectionData = [String]()
    private var activeUsersSectionData = [String]()
    
    init() {
        systemSectionData = Array(repeating: "...", count: systemSectionLabels.count)
        storageSectionData = Array(repeating: "...", count: storageSectionLabels.count)
        serverSectionData = Array(repeating: "...", count: serverSectionLabels.count)
        activeUsersSectionData = Array(repeating: "...", count: activeUsersSectionLabels.count)
    }
    
    // MARK: - Data Parsing and Update
    mutating func updateDataWith(server system: Nextcloud, webServer: Server, users: ActiveUsers) {

        // Update the System Section
        let memoryUsage: String = {
            if let freeMemory = system.system?.memFree?.intValue {
                if let totalMemory = system.system?.memTotal?.intValue {
                    return calculateMemoryUsage(freeMemory: freeMemory, totalMemory: totalMemory)
                }
            }
            
            return "N/A"
        }()
        
        let memory: String = {
            if let freeMemory = system.system?.memFree?.intValue {
                if let totalMemory = system.system?.memTotal?.intValue {
                    return calculateMemory(freeMemory: freeMemory, totalMemory: totalMemory)
                }
            }
            
            return "N/A"
        }()
        
        let swapUsage: String = {
            if let freeMemory = system.system?.swapFree?.intValue {
                if let totalMemory = system.system?.swapTotal?.intValue {
                    return calculateMemoryUsage(freeMemory: freeMemory, totalMemory: totalMemory)
                }
            }
            
            return "N/A"
        }()
        
        let swap: String = {
            if let freeMemory = system.system?.swapFree?.intValue {
                if let totalMemory = system.system?.swapTotal?.intValue {
                    return calculateMemory(freeMemory: freeMemory, totalMemory: totalMemory)
                }
            }
            
            return "N/A"
        }()
        
        systemSectionData[SystemIndex.version.rawValue] = system.system?.version ?? "N/A"
        systemSectionData[SystemIndex.cpuLoad.rawValue] = doubleArrayToString(array: system.system?.cpuload ?? [])
        systemSectionData[SystemIndex.memoryUsage.rawValue] = memoryUsage
        systemSectionData[SystemIndex.memory.rawValue] = memory
        systemSectionData[SystemIndex.swapUsage.rawValue] = swapUsage
        systemSectionData[SystemIndex.swap.rawValue] = swap
        systemSectionData[SystemIndex.localCache.rawValue] = system.system?.memcacheLocal ?? "N/A"
        systemSectionData[SystemIndex.distributedCache.rawValue] = system.system?.memcacheDistributed ?? "N/A"
        
        // Update the Storage Section
        let freeSpace: String = {
            if let value = system.system?.freespace {
                let valueInGigabytes = Double(value) / 1073741824.0
                return "\(String(format: "%.2f", valueInGigabytes)) GB"
            } else {
                return "N/A"
            }
        }()
        
        let numberOfFiles: String = {
            if let value = system.storage?.numFiles {
                return String(value)
            } else {
                return "N/A"
            }
        }()
        
        storageSectionData[StorageIndex.freeSpace.rawValue] = freeSpace
        storageSectionData[StorageIndex.numberOfFiles.rawValue] = numberOfFiles
        
        // Update the Web Server Section
        serverSectionData[ServerIndex.webServer.rawValue] = webServer.webserver ?? "N/A"
        serverSectionData[ServerIndex.phpVersion.rawValue] = webServer.php?.version ?? "N/A"
        serverSectionData[ServerIndex.database.rawValue] = webServer.database?.type ?? "N/A"
        serverSectionData[ServerIndex.databaseVersion.rawValue] = webServer.database?.version ?? "N/A"
        
        // Update the Active Users Section
        let last5: String = {
            if let value = users.last5Minutes {
                return String(value)
            } else {
                return "N/A"
            }
        }()
        
        let lastHour: String = {
            if let value = users.last1Hour {
                return String(value)
            } else {
                return "N/A"
            }
        }()
        
        let lastDay: String = {
            if let value = users.last24Hours {
                return String(value)
            } else {
                return "N/A"
            }
        }()
        
        let total: String = {
            if let value = system.storage?.numUsers {
                return String(value)
            } else {
                return "N/A"
            }
        }()
        
        activeUsersSectionData[ActiveUsersIndex.last5Minutes.rawValue] = last5
        activeUsersSectionData[ActiveUsersIndex.lastHour.rawValue] = lastHour
        activeUsersSectionData[ActiveUsersIndex.lastDay.rawValue] = lastDay
        activeUsersSectionData[ActiveUsersIndex.total.rawValue] = total
        
    }
    
    // MARK: - Data Helper Functions
    func calculateMemory(freeMemory: Int, totalMemory: Int) -> String {
        let totalGB = Double(totalMemory) / 1048576.0
        let totalFree = Double(freeMemory) / 1048576.0
        let memoryUsed = totalGB - totalFree
        let memoryString = "\(String(format: "%.2f", memoryUsed))/\(String(format: "%.2f", totalGB)) GB"
        
        return memoryString
    }
    
    func calculateMemoryUsage(freeMemory: Int, totalMemory: Int) -> String {
        let memoryUsed = totalMemory - freeMemory
        let doubleUsage: Double = (Double(memoryUsed) / Double(totalMemory)) * 100
        let usage = Int(doubleUsage)
        
        return "\(usage)%"
    }
    
    func doubleArrayToString(array: [Double]) -> String {
        // Check that array has a value
        if array.isEmpty { return "N/A" }
        
        var string = ""
        var pass = 0
        
        for number in array {
            if pass == 0 {
                string += "\(number)"
            } else {
                string += ", \(number)"
            }
            pass += 1
        }
        
        if string == "" {
            return "nil"
        } else {
            return string
        }
    }
    
    // MARK: - TableView Data Getters
    func sections() -> Int {
        return sectionLabels.count
    }
    
    func sectionLabel(for section: Int) -> String {
        return sectionLabels[section]
    }
    
    func rows(in section: Int) -> Int {
        switch section {
        case 0:
            return systemSectionLabels.count
        case 1:
            return storageSectionLabels.count
        case 2:
            return serverSectionLabels.count
        case 3:
            return activeUsersSectionLabels.count
        default:
            return 0
        }
    }
    
    func rowLabel(forRow row: Int, inSection section: Int) -> String {
        switch section {
        case 0:
            return systemSectionLabels[row]
        case 1:
            return storageSectionLabels[row]
        case 2:
            return serverSectionLabels[row]
        case 3:
            return activeUsersSectionLabels[row]
        default:
            return "N/A"
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
