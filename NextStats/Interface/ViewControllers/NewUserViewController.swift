//
//  NewUserController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/15/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserViewController: BaseTableViewController {
    // MARK: - Coordinator

    weak var coordinator: NewUserCoordinator?

    // MARK: - Properties

    let dataSource = NewUserDataSource()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        titleText = .localized(.newUser)
        tableStyle = .insetGrouped
        delegate = self
        super.viewDidLoad()
    }

    // MARK: - Configuration

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

    override func setupTableView() {
        super.setupTableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.dataSource = dataSource
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

// MARK: - UITableViewDelegate

extension NewUserViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard
            let section = NewUserSection(rawValue: indexPath.section)
        else { return }

        coordinator?.selectionMade(in: section)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
