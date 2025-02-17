//
//  ServerTableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class ServerTableViewDelegate: NSObject, UITableViewDelegate {
    weak var coordinator: MainCoordinator?
    let serverManager: NXServerManager

    init(coordinator: MainCoordinator?, serverManager: NXServerManager) {
        self.coordinator = coordinator
        self.serverManager = serverManager
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showStatsView(for: serverManager.serverAt(indexPath.row))
    }
}
