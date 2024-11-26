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
        showAlert(title: .localized(.unableToRemove), message: .localized(.unableToRemoveMessage))
    }

    func serversDidChange(refresh: Bool) {
        mainViewController.updateUIBasedOnServerState()

        if refresh { mainViewController.tableView.reloadData() }

        // So iPad doesn't get tableView stuck in editing mode
        mainViewController.setEditing(false, animated: true)
    }

    func serverWiped() {
        mainViewController.navigationController?.popToRootViewController(animated: true)
    }

    func pingedServer(at index: Int, status: ServerStatus) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = mainViewController.tableView.cellForRow(at: indexPath) as? ServerCell
        else { return }

        cell.setStatus(to: status)
    }

    func unauthorized() {
        mainViewController.navigationController?.popToRootViewController(animated: true)
        showAlert(title: .localized(.unauthorized), message: .localized(.unauthorizedDescription))
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .localized(.statsActionContinue), style: .default))
        mainViewController.present(alert, animated: true)
    }
}
