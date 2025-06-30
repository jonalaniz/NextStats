//
//  UserViewController.swift
//  UserViewController
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class UserViewController: BaseTableViewController {
    weak var coordinator: UsersCoordinator?
    let dataManager = NXUserFormatter.shared
    private var tableDelegate: UserTableViewDelegate?

    override func viewDidLoad() {
        tableDelegate = UserTableViewDelegate(dataManager: dataManager)
        delegate = tableDelegate
        tableStyle = .insetGrouped
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        configureTitle()
        tableView.reloadData()
    }

    override func setupNavigationController() {
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
        navigationItem.rightBarButtonItem = moreButton
    }

    override func registerCells() {
        tableView.register(
            ProgressCell.self, forCellReuseIdentifier: ProgressCell.reuseIdentifier
        )
    }

    func configureTitle() {
        title = dataManager.title()
        guard let enabled = dataManager.user?.data.enabled else { return }

        let navigationBar = navigationController?.navigationBar
        let color: UIColor = enabled ? .theme : .systemGray
        let attributes = [
            NSAttributedString.Key.foregroundColor: color
        ]
        navigationBar?.titleTextAttributes = attributes
        navigationBar?.largeTitleTextAttributes = attributes
    }

    @objc func menuTapped() {
        let ableTitle: String = dataManager.enabled() ? .localized(.disable) : .localized(.enable)

        let alertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet
        )
        alertController.addAction(
            UIAlertAction(
                title: ableTitle,
                style: .default,
                handler: toggleAbility
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: .localized(.delete),
                style: .destructive,
                handler: showScareSheet)
        )
        alertController.addAction(
            UIAlertAction(
                title: .localized(.statsActionCancel),
                style: .cancel
            )
        )
        let popover = alertController.popoverPresentationController
        if #available(iOS 16.0, *) {
            popover?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            popover?.barButtonItem = navigationItem.rightBarButtonItem
        }
        present(alertController, animated: true)
    }

    func toggleAbility(action: UIAlertAction) {
        coordinator?.toggle(user: dataManager.userID())
    }

    func showScareSheet(action: UIAlertAction) {
        let alertController = UIAlertController(
            title: .localized(.deleteUser),
            message: "\(String.localized(.deleteUserMessage)) \(dataManager.userID())",
            preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(
                title: .localized(.delete),
                style: .destructive,
                handler: deleteUser)
        )
        alertController.addAction(
            UIAlertAction(
                title: .localized(.statsActionCancel),
                style: .cancel
            )
        )

        present(alertController, animated: true)
    }

    func deleteUser(action: UIAlertAction) {
        coordinator?.delete(user: dataManager.userID())
    }
}
