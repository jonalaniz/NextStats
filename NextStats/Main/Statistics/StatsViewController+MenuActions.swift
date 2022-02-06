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
        ac.addTextField()

        let renameAction = UIAlertAction(title: "Rename", style: .default) { [weak self, weak ac] _ in
            guard let nameString = ac?.textFields?[0].text else { return }
            self?.renameServer(nameString)
        }
        ac.addAction(renameAction)
        present(ac, animated: true)
    }

    @objc func refreshIcon(action: UIAlertAction) {
        print("Refresh Icon")
    }

    @objc func delete(action: UIAlertAction) {
        print("Delete Server")
    }

    func renameServer(_ name: String) {
        guard let server = dataManager.server else { return }
        headerView.nameLabel.text = name
        tableView.tableHeaderView = headerView

        let manager = NextServerManager.shared
        manager.rename(server: server, name: name)
    }
}
