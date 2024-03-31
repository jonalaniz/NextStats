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
            userViewController.setTitleColor()
        case .usersLoaded:
            usersViewController.showData()
        }
    }

    func error(_ error: NXUserManagerErrorType) {
        // Handle error
        switch error {
        case .app(let error):
            switch error {
            case .usersEmpty:
                showError(title: "Error",
                          description: "Users empty, this should not happen. Run for the hills.")
            }
        case .networking(let networkError):
            showError(title: networkError.title, description: networkError.description)
        case .server(let status, let message):
            showError(title: status, description: message)
        }
    }

    private func showError(title: String, description: String) {
        let errorAC = UIAlertController(title: title,
                                        message: description,
                                        preferredStyle: .alert)
        errorAC.addAction(UIAlertAction(title: .localized(.statsActionContinue),
                                        style: .default,
                                        handler: dismissView))
    }

    private func dismissView(action: UIAlertAction) {
        usersViewController.dismissController()
    }
}
