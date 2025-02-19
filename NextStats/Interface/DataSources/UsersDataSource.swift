//
//  UsersDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/19/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class UsersDataSource: NSObject, UITableViewDataSource {
    let usersManager: NXUsersManager

    init(usersManager: NXUsersManager) {
        self.usersManager = usersManager
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersManager.userIDs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let userModel = usersManager.userCellModel(indexPath.row),
            let cell = tableView.dequeueReusableCell(
                withIdentifier: UserCell.reuseIdentifier,
                for: indexPath) as? UserCell
        else { return UITableViewCell() }

        cell.configureCell(with: userModel)

        return cell
    }
}
