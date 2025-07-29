//
//  UsersViewController.swift
//  UsersViewController
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// A view controller that displays a list of users.
class UsersViewController: BaseDataTableViewController {

    // MARK: - Coordinator

    weak var coordinator: UsersCoordinator?

    // MARK: - Properties

    let dataSource = UsersDataSource()

    // MARK: - Views

    let loadingView = LoadingViewController()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        delegate = self

        tableStyle = .insetGrouped
        titleText = .localized(.users)
        super.viewDidLoad()
        tableView.dataSource = dataSource
        showLoadingView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Deselect row when returning to view
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Setup

    override func setupNavigationController() {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme
        ]
        let navigationBar = navigationController?.navigationBar
        navigationBar?.titleTextAttributes = attributes
        navigationBar?.largeTitleTextAttributes = attributes

        let dismissButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissController)
        )
        let newUserButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(showNewUserController)
        )
        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.rightBarButtonItem = newUserButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func registerCells() {
        tableView.register(
            UserCell.self,
            forCellReuseIdentifier: UserCell.reuseIdentifier
        )
    }

    // MARK: - Visibility

    func showLoadingView() {
        guard let tableView = tableView else { return }
        tableView.isHidden = true
        add(loadingView)
    }

    private func showTableView() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        tableView.isHidden = false
        loadingView.remove()
        tableView.reloadData()
    }

    @objc func dismissController() {
        coordinator?.didFinish()
        dismiss(animated: true, completion: nil)
    }

    @objc func showNewUserController() {
        coordinator?.showAddUserView()
    }

    func toggleUser(with id: String) {
        dataSource.toggleUser(with: id)
        tableView.reloadData()
    }

    func updateDataSource(with rows: [UserCellModel]) {
        dataSource.rows = rows
        showTableView()
    }
}

// MARK: - UITableViewDelegate

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showUserView(for: indexPath.row)
    }
}
