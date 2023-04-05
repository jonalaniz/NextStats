//
//  Stat.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/28/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

struct Statistic {
    let title: String
    var value: String = "..."
}

struct StatisticsContainer {
    let sections = [0: "System",
                    1: "Storage",
                    2: "Server",
                    3: "Active Users"]

    private var system = [0: Statistic(title: "Version"),
                  1: Statistic(title: "CPU"),
                  2: Statistic(title: "Memory Usage"),
                  3: Statistic(title: "Memory"),
                  4: Statistic(title: "Swap Usage"),
                  5: Statistic(title: "Swap"),
                  6: Statistic(title: "Local Cache"),
                  7: Statistic(title: "Distributed Cache")]

    private var storage = [0: Statistic(title: "Free Space"),
                   1: Statistic(title: "Number of Files")]

    private var server = [0: Statistic(title: "Web Server"),
                  1: Statistic(title: "PHP Version"),
                  2: Statistic(title: "Database"),
                  3: Statistic(title: "Database Version")]

    private var activeUsers = [0: Statistic(title: "Last 5 Minutes"),
                       1: Statistic(title: "Last Hour"),
                       2: Statistic(title: "Last Day"),
                       3: Statistic(title: "Total Users")]

    func label(for section: Int) -> String {
        guard let label = sections[section] else { return "" }

        return label
    }

    mutating func set(systemData: [String]) {
        for index in 0..<system.count {
            system[index]?.value = systemData[index]
        }
    }

    mutating func set(storageData: [String]) {
        for index in 0..<storage.count {
            storage[index]?.value = storageData[index]
        }
    }

    mutating func set(serverData: [String]) {
        for index in 0..<server.count {
            server[index]?.value = serverData[index]
        }
    }

    mutating func set(userData: [String]) {
        for index in 0..<activeUsers.count {
            activeUsers[index]?.value = userData[index]
        }
    }

    func rows(in section: Int) -> Int {
        switch section {
        case 0: return system.count
        case 1: return storage.count
        case 2: return server.count
        case 3: return activeUsers.count
        default: return 0
        }
    }

    func stat(for row: Int, in section: Int) -> Statistic? {
        switch section {
        case 0: return system[row]
        case 1: return storage[row]
        case 2: return server[row]
        case 3: return activeUsers[row]
        default: return nil
        }
    }

    func title(for section: Int) -> String {
        guard let title = sections[section] else { return "" }

        return title
    }
}
