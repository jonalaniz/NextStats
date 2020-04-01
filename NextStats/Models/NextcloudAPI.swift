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
    
    func imageURL() -> String {
        return friendlyURL.secureURLString() + logoEndpoint
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

// MARK: - AuthResponse
struct AuthResponse: Codable {
    let poll: Poll?
    let login: String?
    
    init(poll: Poll? = nil, login: String? = nil) {
        self.poll = poll
        self.login = login
    }
    
    struct Poll: Codable {
        let token: String?
        let endpoint: String?
        
        init(token: String? = nil, endpoint: String? = nil) {
            self.token = token
            self.endpoint = endpoint
        }
    }
}

// MARK: - ServerAuthenticationInfo
struct ServerAuthenticationInfo: Codable {
    let server: String?
    let loginName: String?
    let appPassword: String?
}

// ----------------------------------------------------------------------------
// MARK: - Server Monitor API JSON Struct
// ----------------------------------------------------------------------------

// MARK: - Monitor
struct Monitor: Codable {
    let ocs: Ocs?
}

// MARK: - Ocs
struct Ocs: Codable {
    let meta: Meta?
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let nextcloud: Nextcloud?
    let server: Server?
    let activeUsers: ActiveUsers?
}

// MARK: - ActiveUsers
struct ActiveUsers: Codable {
    let last5Minutes, last1Hour, last24Hours: Int?

    enum CodingKeys: String, CodingKey {
        case last5Minutes = "last5minutes"
        case last1Hour = "last1hour"
        case last24Hours = "last24hours"
    }
}

// MARK: - Nextcloud
struct Nextcloud: Codable {
    let system: System?
    let storage: Storage?
    let shares: Shares?
}

// MARK: - Shares
struct Shares: Codable {
    let numShares, numSharesUser, numSharesGroups, numSharesLink: Int?
    let numSharesMail, numSharesRoom, numSharesLinkNoPassword, numFedSharesSent: Int?
    let numFedSharesReceived: Int?
    let permissions3_1: String?

    enum CodingKeys: String, CodingKey {
        case numShares = "num_shares"
        case numSharesUser = "num_shares_user"
        case numSharesGroups = "num_shares_groups"
        case numSharesLink = "num_shares_link"
        case numSharesMail = "num_shares_mail"
        case numSharesRoom = "num_shares_room"
        case numSharesLinkNoPassword = "num_shares_link_no_password"
        case numFedSharesSent = "num_fed_shares_sent"
        case numFedSharesReceived = "num_fed_shares_received"
        case permissions3_1 = "permissions_3_1"
    }
}

// MARK: - Storage
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
}

// MARK: - System
struct System: Codable {
    let version, theme, enableAvatars, enablePreviews: String?
    let memcacheLocal, memcacheDistributed, filelockingEnabled, memcacheLocking: String?
    let debug: String?
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
}

// MARK: - Apps
struct Apps: Codable {
    let numInstalled, numUpdatesAvailable: Int?
    let appUpdates: AppUpdates?

    enum CodingKeys: String, CodingKey {
        case numInstalled = "num_installed"
        case numUpdatesAvailable = "num_updates_available"
        case appUpdates = "app_updates"
    }
}

// MARK: - AppUpdates
struct AppUpdates: Codable {
    //let music: String?
}

// MARK: - Server
struct Server: Codable {
    let webserver: String?
    let php: PHP?
    let database: Database?
}

// MARK: - Database
struct Database: Codable {
    let type, version: String?
    let size: Int?
}

// MARK: - PHP
struct PHP: Codable {
    let version: String?
    let memoryLimit, maxExecutionTime, uploadMaxFilesize: Int?

    enum CodingKeys: String, CodingKey {
        case version
        case memoryLimit = "memory_limit"
        case maxExecutionTime = "max_execution_time"
        case uploadMaxFilesize = "upload_max_filesize"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let status: String?
    let statuscode: Int?
    let message: String?
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into hasher: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
        return nil
    }

    required init?(stringValue: String) {
        key = stringValue
    }

    var intValue: Int? {
        return nil
    }

    var stringValue: String {
        return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }

    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}

