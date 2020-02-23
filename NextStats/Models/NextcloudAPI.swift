//
//  NextcloudAPI.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation

let statEndpoint = "/ocs/v2.php/apps/serverinfo/api/v1/info?format=json"
let loginEndpoint = "/index.php/login/v2"
let logoEndpoint = "/index.php/apps/theming/image/logo"

struct NextServer: Codable {
    let name: String
    let friendlyURL: String
    let URLString: String
    let username: String
    let password: String
    let hasCustomLogo: Bool
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    
}

// ----------------------------------------------------------------------------
// MARK: - Authorization Structs
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
// MARK: - JSON Struct
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
        case last5Minutes
        case last1Hour
        case last24Hours
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
        case numShares
        case numSharesUser
        case numSharesGroups
        case numSharesLink
        case numSharesMail
        case numSharesRoom
        case numSharesLinkNoPassword
        case numFedSharesSent
        case numFedSharesReceived
        case permissions3_1
    }
}

// MARK: - Storage
struct Storage: Codable {
    let numUsers, numFiles, numStorages, numStoragesLocal: Int?
    let numStoragesHome, numStoragesOther: Int?

    enum CodingKeys: String, CodingKey {
        case numUsers
        case numFiles
        case numStorages
        case numStoragesLocal
        case numStoragesHome
        case numStoragesOther
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
        case enableAvatars
        case enablePreviews
        case memcacheLocal
        case memcacheDistributed
        case filelockingEnabled
        case memcacheLocking
        case debug, freespace, cpuload
        case memTotal
        case memFree
        case swapTotal
        case swapFree
        case apps
    }
}

// MARK: - Apps
struct Apps: Codable {
    let numInstalled, numUpdatesAvailable: Int?
    let appUpdates: [Int]?

    enum CodingKeys: String, CodingKey {
        case numInstalled
        case numUpdatesAvailable
        case appUpdates
    }
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
        case memoryLimit
        case maxExecutionTime
        case uploadMaxFilesize
    }
}

// MARK: - Meta
struct Meta: Codable {
    let status: String?
    let statuscode: Int?
    let message: String?
}
