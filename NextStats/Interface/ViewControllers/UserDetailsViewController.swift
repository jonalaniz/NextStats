//
//  UserDetailsViewController.swift
//  UserDetailsViewController
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// A view controller that displays a the user details.
class UserDetailsViewController: BaseDataTableViewController {
    // MARK: - Coordinator

    weak var coordinator: UsersCoordinator?

    // MARK: - Properties
    let dataSource = StatisticsDataSource()
    private var user: User?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        delegate = self
        tableStyle = .insetGrouped
        super.viewDidLoad()
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        setNavigationBarColor()
    }

    // MARK: - Setup

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
            GenericCell.self,
            forCellReuseIdentifier: GenericCell.reuseIdentifier
        )
        tableView.register(
            ProgressCell.self, forCellReuseIdentifier: ProgressCell.reuseIdentifier
        )
    }

    func set(_ user: User, sections: [TableSection]) {
        title = user.data.displayname
        self.user = user

        // TableView Part
        dataSource.sections = sections
    }

    private func setNavigationBarColor() {
        guard let enabled = user?.data.enabled else { return }
        print(enabled)
        let navigationBar = navigationController?.navigationBar
        let color: UIColor = enabled ? .theme : .systemGray
        let attributes = [
            NSAttributedString.Key.foregroundColor: color
        ]
        navigationBar?.titleTextAttributes = attributes
        navigationBar?.largeTitleTextAttributes = attributes
    }

    @objc func menuTapped() {
        guard let user = user else { return }
        let ableTitle: String = user.data.enabled ? .localized(.disable) : .localized(.enable)

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
        guard let user = user else { return }
        coordinator?.toggle(user: user.data.id)
    }

    func showScareSheet(action: UIAlertAction) {
        guard let user = user else { return }
        let alertController = UIAlertController(
            title: .localized(.deleteUser),
            message: "\(String.localized(.deleteUserMessage)) \(user.data.id)",
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
        guard let user = user else { return }
        coordinator?.delete(user: user.data.id)
    }

    func toggleUser() {
        user?.data.enabled.toggle()
        setNavigationBarColor()
    }
}

extension UserDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Get number of sections
        let sections = tableView.numberOfSections

        if sections == UserSection.allCases.count {
            return height(for: indexPath.section)
        } else {
            return height(for: indexPath.section + 1)
        }
    }

    private func height(for section: Int) -> CGFloat {
        guard let tableSection = UserSection(rawValue: section)
        else { return 44 }

        return tableSection.rowHeight
    }
}
