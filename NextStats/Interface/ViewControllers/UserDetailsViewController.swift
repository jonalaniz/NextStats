//
//  UserDetailsViewController.swift
//  UserDetailsViewController
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// A view controller that displays a the user details.
final class UserDetailsViewController: BaseTableViewController {

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
        updateNavigationBarColor()
    }

    // MARK: - Setup

    override func setupNavigationController() {
        navigationItem.rightBarButtonItem = makeMoreButton()
    }

    override func registerCells() {
        tableView.register(
            GenericCell.self, forCellReuseIdentifier: GenericCell.reuseIdentifier
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

    // MARK: - UI

    private func makeMoreButton() -> UIBarButtonItem {
        return UIBarButtonItem(
            image: SFSymbol.ellipsis.image,
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )
    }

    private func updateNavigationBarColor() {
        guard let enabled = user?.data.enabled
        else { return }
        navigationController?.navigationBar.setColor(
            enabled ? .theme : .systemGray
        )
    }

    // MARK: - Menu

    @objc private func menuTapped() {
        guard let user = user else { return }
        present(makeMenuFor(user: user), animated: true)
    }

    private func makeMenuFor(user: User) -> UIAlertController {
        let toggleTitle: String = user.data.enabled ? .localized(.disable) : .localized(.enable)

        let actions = [
            UIAlertAction(title: toggleTitle, style: .default, handler: toggleAbility),
            UIAlertAction(title: .localized(.delete), style: .destructive, handler: requestConfirmation),
            UIAlertAction(title: .localized(.statsActionCancel), style: .cancel)
        ]

        let alertController = UIAlertController(
            title: nil, message: nil, preferredStyle: .actionSheet
        )

        actions.forEach(alertController.addAction)

        configurePopover(for: alertController)

        return alertController
    }

    private func configurePopover(for alert: UIAlertController) {
        let popover = alert.popoverPresentationController
        if #available(iOS 16.0, *) {
            popover?.sourceItem = navigationItem.rightBarButtonItem
        } else {
            popover?.barButtonItem = navigationItem.rightBarButtonItem
        }
    }

    // MARK: - Actions

    private func toggleAbility(action: UIAlertAction) {
        guard let user = user else { return }
        coordinator?.toggle(user: user.data.id)
    }

    private func requestConfirmation(action: UIAlertAction) {
        guard let user = user else { return }
        let actions = [
            UIAlertAction(title: .localized(.delete), style: .destructive, handler: deleteUser),
            UIAlertAction(title: .localized(.statsActionCancel), style: .cancel)
        ]

        let alert = UIAlertController(
            title: .localized(.deleteUser),
            message: "\(String.localized(.deleteUserMessage)) \(user.data.id)",
            preferredStyle: .alert)

        actions.forEach(alert.addAction)

        present(alert, animated: true)
    }

    private func deleteUser(action: UIAlertAction) {
        guard let user = user else { return }
        navigationItem.rightBarButtonItem = LoadingBarButtonItem()
        coordinator?.delete(user: user.data.id)
    }

    func userDeleted() {
        navigationItem.rightBarButtonItem = makeMoreButton()
    }

    func toggleUser() {
        user?.data.enabled.toggle()
        updateNavigationBarColor()
    }
}

// MARK: - UITableViewDelegate

extension UserDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.numberOfSections == UserSection.allCases.count {
            return height(for: indexPath.section)
        } else {
            return height(for: indexPath.section + 1)
        }
    }

    private func height(for section: Int) -> CGFloat {
        return UserSection(rawValue: section)?.rowHeight ?? UITableView.automaticDimension
    }
}
