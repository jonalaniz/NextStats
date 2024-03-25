//
//  NewUsersCoordinator+SelectionViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/25/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

extension NewUserCoordinator: SelectionViewDelegate {
    func selected(_ selected: [String], type: SelectionType) {
        switch type {
        case .groups: userFactory.set(groups: selected)
        case .subAdmin: userFactory.set(adminOf: selected)
        case .quota: break
        }

        newUserViewController.tableView.reloadData()
    }

    func selected(_ selection: String, type: SelectionType) {
        if type == .quota { userFactory.set(quota: selection) }

        newUserViewController.tableView.reloadData()
    }
}
