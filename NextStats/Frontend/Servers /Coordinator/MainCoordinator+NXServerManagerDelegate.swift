//
//  MainCoordinator+NXServerManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/29/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension MainCoordinator: NXServerManagerDelegate {
    func deauthorizationFailed(server: NextServer) {
        let errorAC = UIAlertController(title: .localized(.unableToRemove),
                                        message: .localized(.unableToRemoveMessage),
                                        preferredStyle: .alert)

        errorAC.addAction(UIAlertAction(title: .localized(.statsActionContinue),
                                        style: .default))
        mainViewController.present(errorAC, animated: true)
    }

    func serversDidChange(refresh: Bool) {
        serverManager.isEmpty() ? mainViewController.showNoServersVC() : mainViewController.removeNoServersVC()

        if refresh { mainViewController.tableView.reloadData() }

        // So iPad doesn't get tableView stuck in editing mode
        mainViewController.setEditing(false, animated: true)
    }

    func pingedServer(at index: Int, isOnline: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = mainViewController.tableView.cellForRow(at: indexPath) as? ServerCell
        else { return }

        cell.setOnlineStatus(to: isOnline)
    }
}
