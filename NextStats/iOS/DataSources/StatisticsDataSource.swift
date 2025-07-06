//
//  StatsDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/23/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

final class StatisticsDataSource: NSObject, BaseDataSource {
    var sections = [TableSection]()

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return sections[section].title
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cellData = sections[indexPath.section].rows[indexPath.row]

        if let progressData = cellData.progressData {
            return makeProgressCell(tableView, data: progressData)
        }

        return makeCell(tableView, data: cellData)
    }

    func makeCell(
        _ tableView: UITableView, data: TableRow
    ) -> GenericCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: GenericCell.reuseIdentifier
        ) as? GenericCell
        else { fatalError("Failed to dequeue GenericCell") }

        cell.configureCell(with: data)
        return cell
    }

    func makeProgressCell(_ tableView: UITableView, data: ProgressCellData) -> ProgressCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProgressCell.reuseIdentifier
        ) as? ProgressCell
        else { fatalError("Failed ot dequeue ProgressCell") }
        cell.configure(
            free: data.free,
            total: data.total,
            type: data.type
        )
        return cell
    }
}
