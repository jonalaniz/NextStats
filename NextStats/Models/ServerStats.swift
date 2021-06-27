//
//  ServerStats.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz
//

import Foundation

/// Server Monitor API JSON Struct
struct ServerStats: Codable {
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
        case .string(let string):
            return string
        default:
            return nil
        }
    }

    var intValue: Int? {
        switch self {
        case .int(let int):
            return int
        default:
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let data = try? container.decode(String.self) {
            self = .string(data)
            return
        }
        if let data = try? container.decode(Int.self) {
            self = .int(data)
            return
        }
        throw DecodingError.typeMismatch(MemoryValue.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Memory type mismatch"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let data):
            try container.encode(data)
        case .int(let data):
            try container.encode(data)
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
