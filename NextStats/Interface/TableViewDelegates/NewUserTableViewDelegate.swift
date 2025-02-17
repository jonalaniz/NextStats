//
//  NewUserTableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/16/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserTableViewDelegate: NSObject, UITableViewDelegate {
    weak var coordinator: NewUserCoordinator?
    let userFactory: NXUserFactory

    init(coordinator: NewUserCoordinator?, userFactory: NXUserFactory) {
        self.coordinator = coordinator
        self.userFactory = userFactory
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let section = NewUserSection(rawValue: indexPath.section),
            userFactory.groupsAvailable() != nil
        else { return }

        switch section {
        case .groups: coordinator?.showSelectionView(type: .groups)
        case .subAdmin: coordinator?.showSelectionView(type: .subAdmin)
        case .quota: coordinator?.showSelectionView(type: .quota)
        default: return
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
