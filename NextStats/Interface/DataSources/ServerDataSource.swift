//
//  ServerDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class ServerDataSource: NSObject, UITableViewDataSource {
    let serverManager: NXServerManager

    init(serverManager: NXServerManager) {
        self.serverManager = serverManager
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverManager.serverCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ServerCell.reuseIdentifier,
            for: indexPath) as? ServerCell
        else { fatalError("DequeueReusableCell failed while casting") }

        cell.configure(with: serverManager.serverAt(indexPath.row))

        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = indexPath.row
            serverManager.remove(serverManager.serverAt(row), refresh: false)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
