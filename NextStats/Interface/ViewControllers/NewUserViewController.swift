//
//  NewUserController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/15/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserViewController: BaseTableViewController {
    // MARK: - Properties

    private let userFactory = NXUserFactory.shared

    weak var coordinator: NewUserCoordinator?
    private var tableDelegate: NewUserTableViewDelegate?

    override func viewDidLoad() {
        titleText = .localized(.newUser)
        tableStyle = .insetGrouped
        tableDelegate = NewUserTableViewDelegate(
            coordinator: coordinator,
            userFactory: userFactory)
        delegate = tableDelegate
        super.viewDidLoad()
    }

    override func setupNavigationController() {
        let cancel = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePressed)
        )

        navigationItem.leftBarButtonItem = cancel
        navigationItem.rightBarButtonItem = done
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func registerCells() {
        tableView.register(
            InputCell.self,
            forCellReuseIdentifier: InputCell.reuseidentifier
        )
    }

    @objc func cancelPressed() {
        coordinator?.didFinish()
    }

    @objc func donePressed() {
        coordinator?.createUser()
    }

    func enableNextButton() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
