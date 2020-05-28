//
//  NextcloudAPI.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation
import UIKit

let statEndpoint = "/ocs/v2.php/apps/serverinfo/api/v1/info?format=json"
let loginEndpoint = "/index.php/login/v2"
let logoEndpoint = "/index.php/apps/theming/image/logo"

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

struct NextServer: Codable {
    let name: String
    let friendlyURL: String
    let URLString: String
    let username: String
    let password: String
    let hasCustomLogo: Bool
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func imageURL() -> URL {
        let url = URL(string: URLString)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = ""
        
        return (components.url?.appendingPathComponent(logoEndpoint))!
    }
    
    func imagePath() -> String {
        return documentsDirectory.appendingPathComponent("\(friendlyURL).png", isDirectory: true).path
    }
    
    func imageCached() -> Bool {
        let path = imagePath()
        if FileManager.default.fileExists(atPath: path) {
            print(FileManager.default.fileExists(atPath: path))
            return true
        } else {
            print(FileManager.default.fileExists(atPath: path))
            return false
        }
    }
    
    func cachedImage() -> UIImage {
        return UIImage(contentsOfFile: imagePath())!
    }
}

struct tableStat {
    struct tableStatGroup {
        let statGroupType: String
        var stats: [String: String]
    }
    
    let keys = [
        ["Version", "CPU Load", "Memory Usage", "Memory", "Swap Usage", "Swap", "Local Cache", "Distributed Cache"],
        ["Free Space", "Number of Files"],
        ["Webserver", "PHP Version", "Database", "Database Version"],
        ["Last 5 Minutes", "Last Hour", "Last Day", "Total"]
    ]
    
    var tableStatsArray: [tableStatGroup] = {
        let system = tableStatGroup(statGroupType: "System", stats: ["Version": "...", "CPU Load": "...", "Memory Usage": "...", "Memory": "...", "Swap Usage": "...", "Swap": "...", "Local Cache": "...", "Distributed Cache": "..."])
        let storage = tableStatGroup(statGroupType: "Storage", stats: ["Free Space": "...", "Number of Files": "..."])
        let server = tableStatGroup(statGroupType: "Server", stats: ["Webserver": "...", "PHP Version": "...", "Database": "...", "Database Version": "..."])
        let activeUsers = tableStatGroup(statGroupType: "Active Users", stats: ["Last 5 Minutes": "...", "Last Hour": "...", "Last Day": "...", "Total": "..."])
        
        return [system, storage, server, activeUsers]
    }()
    
    mutating func updateStats(with server: Nextcloud, webServer: Server, users: ActiveUsers) {
        let memory = calculateMemory(freeMemory: server.system!.memFree!, totalMemory: server.system!.memTotal!)
        let memoryUsage = calculateMemoryUsage(freeMemory: server.system!.memFree!, totalMemory: server.system!.memTotal!)
        let swap = calculateMemory(freeMemory: server.system!.swapFree!, totalMemory: server.system!.swapTotal!)
        let swapUsage = calculateMemoryUsage(freeMemory: server.system!.swapFree!, totalMemory: server.system!.swapTotal!)
        
        let freeSpace = (Double(server.system!.freespace!) / 1073741824.0)
        
        let numberOfFiles = server.storage!.numFiles!
        
        let last5 = String(users.last5Minutes!)
        let lastHour = String(users.last1Hour!)
        let lastDay = String(users.last24Hours!)
        let total = String(server.storage!.numUsers!)
        
        tableStatsArray[0].stats["Version"] = server.system?.version
        tableStatsArray[0].stats["CPU Load"] = doubleArrayToString(array: server.system!.cpuload!)
        tableStatsArray[0].stats["Memory Usage"] = memoryUsage
        tableStatsArray[0].stats["Memory"] = memory
        tableStatsArray[0].stats["Swap Usage"] = swapUsage
        tableStatsArray[0].stats["Swap"] = swap
        tableStatsArray[0].stats["Local Cache"] = server.system?.memcacheLocal
        tableStatsArray[0].stats["Distributed Cache"] = server.system?.memcacheDistributed
        
        tableStatsArray[1].stats["Free Space"] = "\(String(format: "%.2f", freeSpace)) GB"
        tableStatsArray[1].stats["Number of Files"] = String(numberOfFiles)
        
        tableStatsArray[2].stats["Webserver"] = webServer.webserver
        tableStatsArray[2].stats["PHP Version"] = webServer.php?.version
        tableStatsArray[2].stats["Database"] = webServer.database?.type
        tableStatsArray[2].stats["Database Version"] = webServer.database?.version
        
        tableStatsArray[3].stats["Last 5 Minutes"] = last5
        tableStatsArray[3].stats["Last Hour"] = lastHour
        tableStatsArray[3].stats["Last Day"] = lastDay
        tableStatsArray[3].stats["Total"] = total
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
    let memTotal, memFree, swapTotal, swapFree: Int?
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
        self.memTotal = try container.decode(Int.self, forKey: .memTotal)
        self.memFree = try container.decode(Int.self, forKey: .memFree)
        self.swapTotal = try container.decode(Int.self, forKey: .swapTotal)
        self.swapFree = try container.decode(Int.self, forKey: .swapFree)
        self.apps = try container.decode(Apps.self, forKey: .apps)
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
