//
//  NextStat.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/27/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

// Server Data Label Enums
enum Sections: Int, CaseIterable {
    case system
    case storage
    case server
    case activeUsers
}

enum SystemIndex: Int, CaseIterable {
    case version
    case cpuLoad
    case memoryUsage
    case memory
    case swapUsage
    case swap
    case localCache
    case distributedCache
}

enum StorageIndex: Int, CaseIterable {
    case freeSpace
    case numberOfFiles
}

enum ServerIndex: Int, CaseIterable {
    case webServer
    case phpVersion
    case database
    case databaseVersion
}

enum ActiveUsersIndex: Int, CaseIterable {
    case last5Minutes
    case lastHour
    case lastDay
    case total
}

struct NextStat {
    // MARK: Labels
    private let sectionLabels = ["System", "Storage", "Server", "Active Users"]
    private let systemSectionLabels = ["Version", "CPU", "Memory Usage", "Memory",
                                       "Swap Usage", "Swap", "Local Cache", "Distributed Cache"]
    private let storageSectionLabels = ["Free Space", "Number of Files"]
    private let serverSectionLabels = ["Web Server", "PHP Version", "Database", "Database Version"]
    private let activeUsersSectionLabels = ["Last 5 Minutes", "Last Hour", "Last Day", "Total"]

    // MARK: Server Section Data
    private var systemSectionData = [String]()
    private var storageSectionData = [String]()
    private var serverSectionData = [String]()
    private var activeUsersSectionData = [String]()

    init() {
        initializeSectionData()
    }

    mutating func initializeSectionData() {
        systemSectionData = Array(repeating: "...", count: systemSectionLabels.count)
        storageSectionData = Array(repeating: "...", count: storageSectionLabels.count)
        serverSectionData = Array(repeating: "...", count: serverSectionLabels.count)
        activeUsersSectionData = Array(repeating: "...", count: activeUsersSectionLabels.count)
    }

    mutating func setSystemData(for section: SystemIndex, to string: String) {
        systemSectionData[section.rawValue] = string
    }

    mutating func setStorageData(for section: StorageIndex, to string: String) {
        storageSectionData[section.rawValue] = string
    }

    mutating func setServerData(for section: ServerIndex, to string: String) {
        serverSectionData[section.rawValue] = string
    }

    mutating func setActiveUserData(for section: ActiveUsersIndex, to string: String) {
        activeUsersSectionData[section.rawValue] = string
    }

    func data(forRow row: Int, inSection section: Int) -> String {
        switch section {
        case 0: return systemSectionData[row]
        case 1: return storageSectionData[row]
        case 2: return serverSectionData[row]
        case 3: return activeUsersSectionData[row]
        default: return "N/A"
        }
    }

    func label(forRow row: Int, inSection section: Int) -> String {
        switch section {
        case 0: return systemSectionLabels[row]
        case 1: return storageSectionLabels[row]
        case 2: return serverSectionLabels[row]
        case 3: return activeUsersSectionLabels[row]
        default: return "N/A"
        }
    }

    func section(_ section: Int) -> String {
        return sectionLabels[section]
    }
}
