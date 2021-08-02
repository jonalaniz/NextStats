//
//  NextStat.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/27/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.

import Foundation

struct NextStat {
    let sectionLabels = ["System", "Storage", "Server", "Active Users"]
    let systemSectionLabels = ["Version", "CPU", "Memory Usage", "Memory",
                               "Swap Usage", "Swap", "Local Cache", "Distributed Cache"]
    let storageSectionLabels = ["Free Space", "Number of Files"]
    let serverSectionLabels = ["Web Server", "PHP Version", "Database", "Database Version"]
    let activeUsersSectionLabels = ["Last 5 Minutes", "Last Hour", "Last Day", "Total"]

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

    mutating func setSystemData(version: String,
                                cpuLoad: String,
                                memoryUsage: String,
                                memory: String,
                                swapUsage: String,
                                swap: String,
                                localCache: String,
                                distributedCache: String) {
        systemSectionData = [version, cpuLoad, memoryUsage, memory, swapUsage, swap, localCache, distributedCache]
    }

    mutating func setStorageData(freeSpace: String, numberOfFiles: String) {
        storageSectionData = [freeSpace, numberOfFiles]
    }

    mutating func setServerData(webServer: String,
                                phpVersion: String,
                                database: String,
                                databaseVersion: String) {
        serverSectionData = [webServer, phpVersion, database, databaseVersion]
    }

    mutating func setActiveUserData(last5Minutes: String,
                                    lastHour: String,
                                    lastDay: String,
                                    total: String) {
        activeUsersSectionData = [last5Minutes, lastHour, lastDay, total]
    }

    mutating func activeUserDataNotFound() {
        activeUsersSectionData = Array(repeating: "N/A", count: activeUsersSectionLabels.count)
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
