//
//  MainCoordinator+UITableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/29/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension MainCoordinator: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverManager.serverCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ServerCell
        else { fatalError("DequeueReusableCell failed while casting") }

        cell.server = serverManager.serverAt(indexPath.row)
        cell.setup()

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

extension MainCoordinator: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showStatsView(for: serverManager.serverAt(indexPath.row))
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
