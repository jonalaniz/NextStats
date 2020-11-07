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

// ----------------------------------------------------------------------------
// MARK: - Monitor Struct for TableView
// ----------------------------------------------------------------------------

struct ServerTableViewDataContainer {
    // MARK: - Labels
    let sectionLabels = ["System", "Storage", "Server", "Active Users"]
    let systemSectionLabels = ["Version", "CPU", "Memory Usage", "Memory", "Swap Usage", "Swap", "Local Cache", "Distributed Cache"]
    let storageSectionLabels = ["Free Space", "Number of Files"]
    let serverSectionLabels = ["Web Server", "PHP Version", "Database", "Database Version"]
    let activeUsersSectionLabels = ["Last 5 Minutes", "Last Hour", "Last Day", "Total"]
    
    // MARK: - ServerData
    var systemSectionData = [String]()
    var storageSectionData = [String]()
    var serverSectionData = [String]()
    var activeUsersSectionData = [String]()
    
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

// ----------------------------------------------------------------------------
// MARK: - Authorization Structs - For use when adding server
// ----------------------------------------------------------------------------
struct AuthResponse: Codable {
    let poll: Poll?
    let login: String?
}

struct Poll: Codable {
    let token: String?
    let endpoint: String?
}

struct ServerAuthenticationInfo: Codable {
    let server: String?
    let loginName: String?
    let appPassword: String?
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
