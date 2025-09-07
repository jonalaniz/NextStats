//
//  UsersViewController.swift
//  UsersViewController
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// A view controller that displays a list of users.
class UsersViewController: BaseTableViewController {

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
        configureButtonsAndPlacement()
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
        navigationController?.navigationBar.applyTheme()
    }

    private func configureButtonsAndPlacement() {
        // Dismiss Button - Always the same
        navigationItem.leftBarButtonItem = makeDismissButton()

        // Add User Button
        let addUserButton = makeAddUserButton()
        addUserButton.isEnabled = false

        // Specific placements per OS
        if #available(iOS 26.0, *) {
            // Add User Button goes into Toolbar
            toolbarItems = [.flexibleSpace(), addUserButton]
            navigationController?.isToolbarHidden = false

            // iOS 26 gets a loading button
            navigationItem.rightBarButtonItem = LoadingBarButtonItem()
        } else {
            // Add User Button goes to RightBarButtonItem
            navigationItem.rightBarButtonItem = addUserButton
        }
    }

    override func registerCells() {
        tableView.register(
            UserCell.self,
            forCellReuseIdentifier: UserCell.reuseIdentifier
        )
    }

    // MARK: - Buttons
    private func makeAddUserButton() -> UIBarButtonItem {
        if #available(iOS 26.0, *) {
            return UIBarButtonItem(
                image: SFSymbol.plus.image,
                style: .prominent,
                target: self,
                action: #selector(showNewUserController)
            )
        } else {
            return UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(showNewUserController)
            )
        }
    }

    private func makeDismissButton() -> UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissController)
        )
    }

    // MARK: - Visibility

    func showLoadingView() {
        guard let tableView = tableView else { return }
        tableView.isHidden = true
        add(loadingView)
    }

    private func showTableView() {
        if #available(iOS 26, *) {
            navigationItem.rightBarButtonItem = nil
            toolbarItems?.last?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }

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
