//
//  UsersCoordinator+NXUserManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/30/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension UsersCoordinator: NXUserManagerDelegate {
    func stateDidChange(_ state: NXUserManagerState) {
        switch state {
        case .deletedUser:
            usersViewController.tableView.reloadData()
            navigationController.popViewController(animated: true)
        case .toggledUser:
            usersViewController.tableView.reloadData()
            userViewController.dataManager.user?.data.enabled.toggle()
            userViewController.configureTitle()
        case .usersLoaded:
            usersViewController.toggleLoadingState(isLoading: false)
        }
    }
}
