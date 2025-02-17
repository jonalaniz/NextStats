//
//  InfoTableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class InfoTableViewDelegate: NSObject, UITableViewDelegate {
    weak var coordinator: InfoCoordinator?
    let dataManager: InfoDataManager

    init(coordinator: InfoCoordinator?, dataManager: InfoDataManager) {
        self.coordinator = coordinator
        self.dataManager = dataManager
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let tableSection = InfoSection(rawValue: indexPath.section)
        else { return }

        let row = indexPath.row

        switch tableSection {
        case .icon: dataManager.toggleIcon()
        case .licenses:
            guard let license = License(rawValue: row) else { return }
            coordinator?.showWebView(urlString: license.urlString)
        case .support: dataManager.buyProduct(row)
        default: return
        }
    }
}
