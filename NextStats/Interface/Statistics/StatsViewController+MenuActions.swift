//
//  ServerMenu.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/4/22.
//  Copyright © 2022 Jon Alaniz.
//

import UIKit

extension StatsViewController {
    @objc func showRenameSheet(action: UIAlertAction) {
        // Create Alert Controller
        let alertController = UIAlertController(
            title: .localized(.statsActionRenameTitle),
            message: "",
            preferredStyle: .alert
        )

        // Create Rename Action
        let rename = UIAlertAction(
            title: .localized(.statsActionRename),
            style: .default) { [weak self, weak alertController] _ in
            guard let nameString = alertController?.textFields?[0].text
                else { return }
            self?.renameServer(nameString)
        }

        // Create Cancel Action
        let cancel = UIAlertAction(
            title: .localized(.statsActionCancel),
            style: .cancel
        )

        // Add the Actions to the Alert Controller
        alertController.addAction(rename)
        alertController.addAction(cancel)

        // Disable the Rename Action
        rename.isEnabled = false

        // Add a text field to the alert controller
        alertController.addTextField { textField in

            // Observe the UITextFieldTextDidChange notification to be notified in the below block when text is changed.
            NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: textField,
                queue: OperationQueue.main) { _ in
                // Something fired the UITextFieldTextDidChange notificaiton,
                // access the textField object from ac.addTextfield(_:) and
                // get character count sans whitespace
                let textCount = textField.text?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).count ?? 0
                let textIsEmpty = textCount == 0

                rename.isEnabled = !textIsEmpty
            }
        }

        // Present the UIAlertAction
        present(alertController, animated: true)
    }

    @objc func delete(action: UIAlertAction) {
        let alertController = UIAlertController(
            title: .localized(.statsActionDeleteTitle),
            message: .localized(.statsActionDeleteMessage),
            preferredStyle: .alert
        )
        let delete = UIAlertAction(
            title: .localized(.statsActionDelete),
            style: .destructive) { [weak self] _ in
            self?.delete()
        }
        let cancel = UIAlertAction(
            title: .localized(.statsActionCancel),
            style: .cancel
        )
        alertController.addAction(delete)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }

    func renameServer(_ name: String) {
        guard let server = dataManager.server else { return }
        headerView.nameLabel.text = name
        tableView.tableHeaderView = headerView

        let manager = NXServerManager.shared

        manager.renameServer(server, to: name) { newServer in
            dataManager.server = newServer
        }
    }

    func delete() {
        guard let server = dataManager.server else { return }
        let manager = NXServerManager.shared
        manager.remove(server, renaming: false, refresh: true)

        dismissView(action: nil)
    }
}
