//
//  NewUserController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/15/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

final class NewUserViewController: BaseTableViewController {

    // MARK: - Coordinator

    weak var coordinator: NewUserCoordinator?

    // MARK: - Properties

    private let dataSource = NewUserDataSource()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        delegate = self
        tableStyle = .insetGrouped
        titleText = .localized(.newUser)
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Setup

    override func setupNavigationController() {
        navigationItem.leftBarButtonItem = makeCancelButton()
        navigationItem.rightBarButtonItem = makeDoneButton()
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

    // MARK: - Buttons
    private func makeCancelButton() -> UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
    }

    private func makeDoneButton() -> UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePressed)
        )
    }

    @objc func cancelPressed() {
        coordinator?.didFinish()
    }

    @objc func donePressed() {
        coordinator?.createUser()
    }

    func enableDoneButton() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    func setLoadingState() {
        navigationItem.rightBarButtonItem = LoadingBarButtonItem()
        navigationItem.rightBarButtonItem?.isEnabled = true
        UIView.animate(withDuration: 0.25) {
            self.tableView.layer.opacity = 0.5
        }
    }

    func resetState() {
        navigationItem.rightBarButtonItem = makeDoneButton()
        tableView.layer.opacity = 1
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
