//
//  NewUserController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/15/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserController: BaseTableViewController {
    weak var coordinator: NewUserCoordinator?

    override func viewDidLoad() {
        titleText = .localized(.newUser)
        tableStyle = .insetGrouped
        super.viewDidLoad()
    }

    override func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true

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
        tableView.register(InputCell.self, forCellReuseIdentifier: "InputCell")
    }

    @objc func cancelPressed() {
        coordinator?.dismiss()
    }

    @objc func donePressed() {
        coordinator?.createUser()
    }
}
