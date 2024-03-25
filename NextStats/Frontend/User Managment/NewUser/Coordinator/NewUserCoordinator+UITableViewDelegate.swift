//
//  NewUserCoordinator+UITableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/21/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension NewUserCoordinator: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let section = NewUserFields(rawValue: indexPath.section),
            userFactory.groupsAvailable() != nil
        else { return }

        switch section {
        case .groups: showSelectionView(type: .groups)
        case .subAdmin: showSelectionView(type: .subAdmin)
        case .quota: showSelectionView(type: .quota)
        default: return
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
