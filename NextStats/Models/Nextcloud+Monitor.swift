//
//  NextcloudAPI.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation

// ----------------------------------------------------------------------------
// MARK: - Enums
// ----------------------------------------------------------------------------

// Server Error Types + Return Strings
enum ServerError {
    case unauthorized
    case noResponse
    case jsonError
    case other
    
    var typeAndDescription: (title: String, description: String) {
        switch self {
        case .unauthorized:
            return("Unauthorized User", "You must have admin privilidges to view server stats. Please check with your administrator.")
        case .noResponse:
            return("No Response", "Your server cannot be reached, please check your internet connection or contact your adminstrator.")
        case .jsonError:
            return("JSON Error", "Could not parse JSON. Please check with your administrator.")
        case .other:
            return("Error", "Unspecified error, server cannot be reached")
        }
    }
}

// Stat enums for tableview
enum StatGroup: String, CaseIterable {
    case system = "System"
    case storage = "Storage"
    case server = "Server"
    case activeUsers = "Active Users"
}

enum SystemEnum: String, CaseIterable {
    case version = "Version"
    case cpuLoad = "CPU Load"
    case memoryUsage = "Memory Usage"
    case memory = "Memory"
    case swapUsage = "Swap Usage"
    case swap = "Swap"
    case localCache = "Local Cache"
    case distributedCache = "Distributed Cache"
}

enum StorageEnum: String, CaseIterable {
    case freeSpace = "Free Space"
    case numberOfFiles = "Number of Files"
}

enum ServerEnum: String, CaseIterable {
    case webServer = "Web Server"
    case phpVersion = "PHP Version"
    case database = "Database"
    case databaseVersion = "Database Version"
}

enum ActiveUsersEnum: String, CaseIterable {
    case last5Minutes = "Last 5 Minutes"
    case lastHour = "Last Hour"
    case lastDay = "Last Day"
    case total = "Total"
}

// ----------------------------------------------------------------------------
// MARK: - Monitor Struct for TableView
// ----------------------------------------------------------------------------

struct tableStat {

    var statsArray = [
        Array(repeating: "...", count: SystemEnum.allCases.count),
        Array(repeating: "...", count: StorageEnum.allCases.count),
        Array(repeating: "...", count: ServerEnum.allCases.count),
        Array(repeating: "...", count: ActiveUsersEnum.allCases.count)
    ]
    
    mutating func updateStats(with server: Nextcloud, webServer: Server, users: ActiveUsers) {
        var memory = "N/A"
        var memoryUsage = "N/A"
        var swap = "N/A"
        var swapUsage = "N/A"
        
        // If memory values are present, calculate and insert values
        if server.system?.memTotal?.intValue != nil {
            memory = calculateMemory(freeMemory: server.system!.memFree!.intValue!, totalMemory: server.system!.memTotal!.intValue!)
            memoryUsage = calculateMemoryUsage(freeMemory: server.system!.memFree!.intValue!, totalMemory: server.system!.memTotal!.intValue!)
            swap = calculateMemory(freeMemory: server.system!.swapFree!.intValue!, totalMemory: server.system!.swapTotal!.intValue!)
            swapUsage = calculateMemoryUsage(freeMemory: server.system!.swapFree!.intValue!, totalMemory: server.system!.swapTotal!.intValue!)
        }
        
        let freeSpace = (Double(server.system!.freespace!) / 1073741824.0)
        
        let numberOfFiles = server.storage!.numFiles!
        
        let last5 = String(users.last5Minutes!)
        let lastHour = String(users.last1Hour!)
        let lastDay = String(users.last24Hours!)
        let total = String(server.storage!.numUsers!)
        
        statsArray[StatGroup.system.index!][SystemEnum.version.index!] = (server.system?.version) ?? "N/A"
        statsArray[StatGroup.system.index!][SystemEnum.cpuLoad.index!] = doubleArrayToString(array: server.system!.cpuload!)
        statsArray[StatGroup.system.index!][SystemEnum.memoryUsage.index!] = memoryUsage
        statsArray[StatGroup.system.index!][SystemEnum.memory.index!] = memory
        statsArray[StatGroup.system.index!][SystemEnum.swapUsage.index!] = swapUsage
        statsArray[StatGroup.system.index!][SystemEnum.swap.index!] = swap
        statsArray[StatGroup.system.index!][SystemEnum.localCache.index!] = (server.system?.memcacheLocal) ?? "N/A"
        statsArray[StatGroup.system.index!][SystemEnum.distributedCache.index!] = server.system?.memcacheDistributed ?? "N/A"
        
        statsArray[StatGroup.storage.index!][StorageEnum.freeSpace.index!] = "\(String(format: "%.2f", freeSpace)) GB"
        statsArray[StatGroup.storage.index!][StorageEnum.numberOfFiles.index!] = String(numberOfFiles)
        
        statsArray[StatGroup.server.index!][ServerEnum.webServer.index!] = webServer.webserver ?? "N/A"
        statsArray[StatGroup.server.index!][ServerEnum.phpVersion.index!] = webServer.php?.version ?? "N/A"
        statsArray[StatGroup.server.index!][ServerEnum.database.index!] = webServer.database?.type ?? "N/A"
        statsArray[StatGroup.server.index!][ServerEnum.databaseVersion.index!] = webServer.database?.version ?? "N/A"
        
        statsArray[StatGroup.activeUsers.index!][ActiveUsersEnum.last5Minutes.index!] = last5
        statsArray[StatGroup.activeUsers.index!][ActiveUsersEnum.lastHour.index!] = lastHour
        statsArray[StatGroup.activeUsers.index!][ActiveUsersEnum.lastDay.index!] = lastDay
        statsArray[StatGroup.activeUsers.index!][ActiveUsersEnum.total.index!] = total
    }
    
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
    
    func getStatLabel(forRow row: Int, inSection section: Int) -> String {
        switch section {
        case StatGroup.system.index:
            return SystemEnum.allCases[row].rawValue
        case StatGroup.storage.index:
            return StorageEnum.allCases[row].rawValue
        case StatGroup.server.index:
            return ServerEnum.allCases[row].rawValue
        case StatGroup.activeUsers.index:
            return ActiveUsersEnum.allCases[row].rawValue
        default:
            return "You shouldn't be here"
        }
    }
    
    func getArrayIndex(for group: StatGroup) -> Int {
        switch group {
        case .system:
            return 0
        case .storage:
            return 1
        case .server:
            return 2
        case .activeUsers:
            return 3
        }
    }
}

// ----------------------------------------------------------------------------
// MARK: - Server Monitor API JSON Struct
// ----------------------------------------------------------------------------

struct Monitor: Codable {
    let ocs: Ocs?
}

struct Ocs: Codable {
    let meta: Meta?
    let data: DataClass?
}

struct Meta: Codable {
    let status: String?
    let statuscode: Int?
    let message: String?
}

struct DataClass: Codable {
    let nextcloud: Nextcloud?
    let server: Server?
    let activeUsers: ActiveUsers?
}

struct Nextcloud: Codable {
    let system: System?
    let storage: Storage?
    let shares: Shares?
}

struct System: Codable {
    let version, theme, enableAvatars, enablePreviews, memcacheLocal: String?
    let memcacheDistributed, filelockingEnabled, memcacheLocking, debug: String?
    let freespace: Int?
    let cpuload: [Double]?
    let memTotal, memFree, swapTotal, swapFree: MemoryValue?
    let apps: Apps?
    
    enum CodingKeys: String, CodingKey {
        case version, theme
        case enableAvatars = "enable_avatars"
        case enablePreviews = "enable_previews"
        case memcacheLocal = "memcache.local"
        case memcacheDistributed = "memcache.distributed"
        case filelockingEnabled = "filelocking.enabled"
        case memcacheLocking = "memcache.locking"
        case debug, freespace, cpuload
        case memTotal = "mem_total"
        case memFree = "mem_free"
        case swapTotal = "swap_total"
        case swapFree = "swap_free"
        case apps
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(String.self, forKey: .version)
        self.theme = try container.decode(String.self, forKey: .theme)
        self.enableAvatars = try container.decode(String.self, forKey: .enableAvatars)
        self.enablePreviews = try container.decode(String.self, forKey: .enablePreviews)
        self.memcacheLocal = try container.decode(String.self, forKey: .memcacheLocal)
        self.memcacheDistributed = try container.decode(String.self, forKey: .memcacheDistributed)
        self.filelockingEnabled = try container.decode(String.self, forKey: .filelockingEnabled)
        self.memcacheLocking = try container.decode(String.self, forKey: .memcacheLocking)
        self.debug = try container.decode(String.self, forKey: .debug)
        self.freespace = try container.decode(Int.self, forKey: .freespace)
        self.cpuload = try container.decode([Double].self, forKey: .cpuload)
        self.memTotal = try container.decode(MemoryValue.self, forKey: .memTotal)
        self.memFree = try container.decode(MemoryValue.self, forKey: .memFree)
        self.swapTotal = try container.decode(MemoryValue.self, forKey: .swapTotal)
        self.swapFree = try container.decode(MemoryValue.self, forKey: .swapFree)
        self.apps = try container.decode(Apps.self, forKey: .apps)
    }
}

// Nextcloud memory values can sometimes be "N/A"
enum MemoryValue: Codable {
    case string(String)
    case int(Int)
    
    var stringValue: String? {
        switch self {
        case .string(let s):
            return s
        default:
            return nil
        }
    }
    
    var intValue: Int? {
        switch self {
        case .int(let i):
            return i
        default:
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Int.self) {
            self = .int(x)
            return
        }
        throw DecodingError.typeMismatch(MemoryValue.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Memory type mismatch"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .int(let x):
            try container.encode(x)
        }
    }
}

struct Apps: Codable {
    let numInstalled, numUpdatesAvailable: Int?
    let appUpdates: AppUpdates?
    
    enum CodingKeys: String, CodingKey {
        case numInstalled = "num_installed"
        case numUpdatesAvailable = "num_updates_available"
        case appUpdates = "app_updates"
    }
    
    init(from decoder: Decoder) throws {
        let containter = try decoder.container(keyedBy: CodingKeys.self)
        self.numInstalled = try containter.decode(Int.self, forKey: .numInstalled)
        self.numUpdatesAvailable = try containter.decode(Int.self, forKey: .numUpdatesAvailable)
        self.appUpdates = try containter.decode(AppUpdates.self, forKey: .appUpdates)
    }
}

struct AppUpdates: Codable {
    // appUpdates are ignored
}

struct Storage: Codable {
    let numUsers, numFiles, numStorages, numStoragesLocal: Int?
    let numStoragesHome, numStoragesOther: Int?

    enum CodingKeys: String, CodingKey {
        case numUsers = "num_users"
        case numFiles = "num_files"
        case numStorages = "num_storages"
        case numStoragesLocal = "num_storages_local"
        case numStoragesHome = "num_storages_home"
        case numStoragesOther = "num_storages_other"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.numUsers = try container.decode(Int.self, forKey: .numUsers)
        self.numFiles = try container.decode(Int.self, forKey: .numFiles)
        self.numStorages = try container.decode(Int.self, forKey: .numStorages)
        self.numStoragesLocal = try container.decode(Int.self, forKey: .numStoragesLocal)
        self.numStoragesHome = try container.decode(Int.self, forKey: .numStoragesHome)
        self.numStoragesOther = try container.decode(Int.self, forKey: .numStoragesOther)
    }
}

struct Shares: Codable {
    // Shares are ignored
}

struct Server: Codable {
    let webserver: String?
    let php: PHP?
    let database: Database?
}

struct PHP: Codable {
    let version: String?
    let memoryLimit, maxExecutionTime, uploadMaxFilesize: Int?
    
    enum CodingKeys: String, CodingKey {
        case version
        case memoryLimit = "memory_limit"
        case maxExecutionTime = "max_execution_time"
        case uploadMaxFilesize = "upload_max_filesize"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(String.self, forKey: .version)
        self.memoryLimit = try container.decode(Int.self, forKey: .memoryLimit)
        self.maxExecutionTime = try container.decode(Int.self, forKey: .maxExecutionTime)
        self.uploadMaxFilesize = try container.decode(Int.self, forKey: .uploadMaxFilesize)
    }
}

struct Database: Codable {
    let type, version: String?
    let size: Int?
}

struct ActiveUsers: Codable {
    let last5Minutes, last1Hour, last24Hours: Int?
    
    enum CodingKeys: String, CodingKey {
        case last5Minutes = "last5minutes"
        case last1Hour = "last1hour"
        case last24Hours = "last24hours"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.last5Minutes = try container.decode(Int.self, forKey: .last5Minutes)
        self.last1Hour = try container.decode(Int.self, forKey: .last1Hour)
        self.last24Hours = try container.decode(Int.self, forKey: .last24Hours)
    }
}
