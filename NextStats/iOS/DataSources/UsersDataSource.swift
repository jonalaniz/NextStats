//
//  UsersDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/19/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class UsersDataSource: NSObject, UITableViewDataSource {
    var rows = [UserCellModel]()

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return rows.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UserCell.reuseIdentifier,
                for: indexPath
            ) as? UserCell
        else { return UITableViewCell() }
        cell.configure(with: rows[indexPath.row])
        return cell
    }

    func toggleUser(with id: String) {
        guard let index = rows.firstIndex(
            where: { $0.userID == id }
        )
        else { return }
        rows[index] = rows[index].toggled()
    }
}
