//
//  StatsDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/23/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

final class ServerStatsDataSource: NSObject, UITableViewDataSource {
    var sections = [TableSection]()

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = sections[indexPath.section].rows[indexPath.row]

        if let progressData = cellData.progressData {
            return progressCell(with: progressData)
        }

        return BaseTableViewCell(
            style: cellData.style,
            text: cellData.title,
            secondaryText: cellData.secondaryText
        )
    }

    private func progressCell(with data: ProgressCellData) -> ProgressCell {
        return ProgressCell(
            free: data.free,
            total: data.total,
            type: data.type
        )
    }
}
