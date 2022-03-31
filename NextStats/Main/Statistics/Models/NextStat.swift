//
//  Stat.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/28/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

struct NextStat {
    let title: String
    var value: String = "..."
}

struct NextStats {
    let sections = [0: "System",
                    1: "Storage",
                    2: "Server",
                    3: "Active Users"]

    private var system = [0: NextStat(title: "Version"),
                  1: NextStat(title: "CPU"),
                  2: NextStat(title: "Memory Usage"),
                  3: NextStat(title: "Memory"),
                  4: NextStat(title: "Swap Usage"),
                  5: NextStat(title: "Swap"),
                  6: NextStat(title: "Local Cache"),
                  7: NextStat(title: "Distributed Cache")]

    private var storage = [0: NextStat(title: "Free Space"),
                   1: NextStat(title: "Number of Files")]

    private var server = [0: NextStat(title: "Web Server"),
                  1: NextStat(title: "PHP Version"),
                  2: NextStat(title: "Database"),
                  3: NextStat(title: "Database Version")]

    private var activeUsers = [0: NextStat(title: "Last 5 Minutes"),
                       1: NextStat(title: "Last Hour"),
                       2: NextStat(title: "Last Day"),
                       3: NextStat(title: "Total Users")]

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

    func stat(for row: Int, in section: Int) -> NextStat? {
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
