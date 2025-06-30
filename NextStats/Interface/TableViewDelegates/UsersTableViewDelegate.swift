//
//  UsersTableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/16/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class UsersTableViewDelegate: NSObject, UITableViewDelegate {
    weak var coordinator: UsersCoordinator?
    let dataManager: NXUsersManager

    init(coordinator: UsersCoordinator? = nil, dataManager: NXUsersManager) {
        self.coordinator = coordinator
        self.dataManager = dataManager
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userModel = dataManager.userCellModel(indexPath.row) else { return }
        let user = dataManager.user(id: userModel.userID)
        coordinator?.showUserView(for: user)
    }
}
