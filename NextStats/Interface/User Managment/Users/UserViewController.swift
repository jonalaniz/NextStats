//
//  UserViewController.swift
//  UserViewController
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

// swiftlint:disable identifier_name
class UserViewController: BaseTableViewController {
    weak var coordinator: UsersCoordinator?
    let dataManager = NXUserFormatter.shared

    override func viewDidLoad() {
        delegate = self
        tableStyle = .insetGrouped
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        configureTitle()
        tableView.reloadData()
    }

    override func setupNavigationController() {
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(menuTapped))
        navigationItem.rightBarButtonItem = moreButton
    }

    override func registerCells() {
        tableView.register(ProgressCell.self, forCellReuseIdentifier: ProgressCell.reuseIdentifier)
    }

    func configureTitle() {
        title = dataManager.title()
        guard let enabled = dataManager.user?.data.enabled else { return }

        let color: UIColor = enabled ? .theme : .systemGray
        let attributes = [NSAttributedString.Key.foregroundColor: color]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.largeTitleTextAttributes = attributes
    }

    @objc func menuTapped() {
        let ableTitle: String = dataManager.enabled() ? .localized(.disable) : .localized(.enable)

        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: ableTitle,
                                   style: .default,
                                   handler: toggleAbility))
        ac.addAction(UIAlertAction(title: .localized(.delete),
                                   style: .destructive,
                                   handler: showScareSheet))
        ac.addAction(UIAlertAction(title: .localized(.statsActionCancel), style: .cancel))
        if #available(iOS 16.0, *) {
            ac.popoverPresentationController?.sourceItem = self.navigationItem.rightBarButtonItem
        } else {
            ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        present(ac, animated: true)
    }

    func toggleAbility(action: UIAlertAction) {
        coordinator?.toggle(user: dataManager.userID())
    }

    func showScareSheet(action: UIAlertAction) {
        let ac = UIAlertController(title: .localized(.deleteUser),
                                   message: "\(String.localized(.deleteUserMessage)) \(dataManager.userID())",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: .localized(.delete),
                                   style: .destructive,
                                   handler: deleteUser))
        ac.addAction(UIAlertAction(title: .localized(.statsActionCancel), style: .cancel))

        present(ac, animated: true)
    }

    func deleteUser(action: UIAlertAction) {
        coordinator?.delete(user: dataManager.userID())
    }
}

extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldHide(section: section) ? CGFloat.leastNonzeroMagnitude : 20
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableSection = UserSection(rawValue: indexPath.section)
        else { return 44 }

        return tableSection.height
    }

    func shouldHide(section: Int) -> Bool {
        guard
            let tableSection = UserSection(rawValue: section),
            tableSection == .mail
        else { return false }

        return dataManager.emailAddresses() == nil
    }
}
