//
//  NXStatsManager+UITableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/29/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

extension NXStatsManager: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return container.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return container.rows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let section = indexPath.section
        let row = indexPath.row

        guard let stat = container.stat(for: row, in: section) else { return cell }

        var content = cell.defaultContentConfiguration()
        content.text = stat.title
        content.secondaryText = stat.value
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return container.title(for: section)
    }
}
