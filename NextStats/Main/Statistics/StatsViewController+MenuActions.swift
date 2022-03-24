//
//  ServerMenu.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/4/22.
//  Copyright © 2022 Jon Alaniz. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name
extension StatsViewController {
    @objc func showRenameSheet(action: UIAlertAction) {
        guard let name = dataManager.server?.name else { return }

        let ac = UIAlertController(title: "Enter a new name for \(name)",
                                   message: "",
                                   preferredStyle: .alert)
        let rename = UIAlertAction(title: "Rename", style: .default) { [weak self, weak ac] _ in
            guard let nameString = ac?.textFields?[0].text else { return }
            self?.renameServer(nameString)
        }
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel)
        ac.addTextField()
        ac.addAction(rename)
        ac.addAction(cancel)
        present(ac, animated: true)
    }

    @objc func refreshIcon(action: UIAlertAction) {
        print("Refresh Icon")
    }

    @objc func delete(action: UIAlertAction) {
        guard let name = dataManager.server?.name else { return }
        let ac = UIAlertController(title: "Are you sure you want to delete \(name)?",
                                   message: "This cannot be undone.",
                                   preferredStyle: .alert)
        let delete = UIAlertAction(title: "Delete",
                                   style: .destructive) { [weak self] _ in
            self?.delete()
        }
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel)
        ac.addAction(delete)
        ac.addAction(cancel)
        present(ac, animated: true)
    }

    func renameServer(_ name: String) {
        guard let server = dataManager.server else { return }
        headerView.nameLabel.text = name
        tableView.tableHeaderView = headerView

        let manager = NextServerManager.shared
        // This will soon become a closure to return the new server object.
        manager.rename(server: server, name: name) { newServer in
            dataManager.server = newServer
        }
    }

    func delete() {
        guard let server = dataManager.server else { return }
        let manager = NextServerManager.shared
        manager.remove(server, imageCache: true)

        returnToTable(action: nil)
    }
}
