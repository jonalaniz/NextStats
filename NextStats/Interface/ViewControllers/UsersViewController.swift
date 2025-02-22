//
//  UsersViewController.swift
//  UsersViewController
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

// swiftlint:disable weak_delegate
/// A view controller that displays a list of users.
class UsersViewController: BaseTableViewController {
    weak var coordinator: UsersCoordinator?
    let dataManager = NXUsersManager.shared
    private var tableDelegate: UsersTableViewDelegate?
    let loadingViewController = LoadingViewController()

    override func viewDidLoad() {
        tableDelegate = UsersTableViewDelegate(
            coordinator: coordinator,
            dataManager: dataManager)
        delegate = tableDelegate

        tableStyle = .insetGrouped
        titleText = .localized(.users)
        super.viewDidLoad()
        toggleLoadingState(isLoading: true)
        dataManager.fetchUsersData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Deselect row when returning to view
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    override func setupNavigationController() {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.theme]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.largeTitleTextAttributes = attributes

        let dismissButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                            target: self,
                                            action: #selector(dismissController))
        let newUserButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(showNewUserController))
        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.rightBarButtonItem = newUserButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func registerCells() {
        tableView.register(UserCell.self,
                           forCellReuseIdentifier: UserCell.reuseIdentifier)
    }

    func toggleLoadingState(isLoading: Bool) {
        tableView.isHidden = isLoading

        if isLoading { add(loadingViewController) } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            tableView.reloadData()
            loadingViewController.remove()
        }
    }

    @objc func dismissController() {
        coordinator?.didFinish()
        dismiss(animated: true, completion: nil)
    }

    @objc func showNewUserController() {
        coordinator?.showAddUserView()
    }
}
