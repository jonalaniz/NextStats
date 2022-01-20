//
//  Stat.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/28/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

struct Stat {
    let title: String
    var value: String = "..."
}

struct Stats {
    let sections = [0: "System",
                    1: "Storage",
                    2: "Server",
                    3: "Active Users"]

    var system = [0: Stat(title: "Version"),
                  1: Stat(title: "CPU"),
                  2: Stat(title: "Memory Usage"),
                  3: Stat(title: "Memory"),
                  4: Stat(title: "Swap"),
                  5: Stat(title: "Swap Usage"),
                  6: Stat(title: "Local Cache"),
                  7: Stat(title: "Distributed Cache")]

    var storage = [0: Stat(title: "Free Space"),
                   1: Stat(title: "Number of Files")]

    var server = [0: Stat(title: "Web Server"),
                  1: Stat(title: "PHP Version"),
                  2: Stat(title: "Database"),
                  3: Stat(title: "Database Version")]

    var activeUsers = [0: Stat(title: "Last 5 Minutes"),
                       1: Stat(title: "Last Hour"),
                       2: Stat(title: "Last Day"),
                       3: Stat(title: "Total Users")]

    func label(for section: Int) -> String {
        guard let label = sections[section] else { return "" }

        return label
    }

    mutating func set(systemData: [String]) {
        for data in systemData {
            let index = systemData.firstIndex(of: data)!
            system[index]?.value = data
        }
    }

    mutating func set(storageData: [String]) {
        for data in storageData {
            let index = storageData.firstIndex(of: data)!
            storage[index]?.value = data
        }
    }

    mutating func set(serverData: [String]) {
        for data in serverData {
            let index = serverData.firstIndex(of: data)!
            server[index]?.value = data
        }
    }

    mutating func set(userData: [String]) {
        for data in userData {
            let index = userData.firstIndex(of: data)!
            activeUsers[index]?.value = data
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

    func stat(for row: Int, in section: Int) -> Stat? {
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
