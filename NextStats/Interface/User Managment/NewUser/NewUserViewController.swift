//
//  NewUserController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/15/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserViewController: BaseTableViewController {
    weak var coordinator: NewUserCoordinator?
    let userFactory = NXUserFactory.shared

    override func viewDidLoad() {
        titleText = .localized(.newUser)
        tableStyle = .insetGrouped
        delegate = self
        super.viewDidLoad()
    }

    override func setupNavigationController() {
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel,
                                     target: self,
                                     action: #selector(cancelPressed))
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self,
                                   action: #selector(donePressed))

        navigationItem.leftBarButtonItem = cancel
        navigationItem.rightBarButtonItem = done
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func registerCells() {
        tableView.register(InputCell.self, forCellReuseIdentifier: InputCell.reuseidentifier)
    }

    @objc func cancelPressed() {
        coordinator?.dismiss()
    }

    @objc func donePressed() {
        coordinator?.createUser()
    }
}

extension NewUserViewController: UITableViewDelegate {
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
