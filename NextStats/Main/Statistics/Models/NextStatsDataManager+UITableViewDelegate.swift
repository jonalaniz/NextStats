//
//  NextStatsDataManager+UITableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/29/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

extension NextStatsDataManager: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return nextStats.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nextStats.rows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let section = indexPath.section
        let row = indexPath.row

        guard let stat = nextStats.stat(for: row, in: section) else { return cell }

        var content = cell.defaultContentConfiguration()
        content.text = stat.title
        content.secondaryText = stat.value
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nextStats.title(for: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
}
