//
//  UserViewController.swift
//  UserViewController
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

// swiftlint:disable identifier_name
class UserViewController: UIViewController {
    weak var coordinator: UsersCoordinator?

    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let dataManager = NXUserFormatter.shared

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupMenu()
    }

    func setupView() {
        view.backgroundColor = .systemBackground
        title = dataManager.title()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self

        tableView.register(ProgressCell.self, forCellReuseIdentifier: "QuotaCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    func setupMenu() {
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(menuTapped))
        navigationItem.rightBarButtonItem = moreButton
    }

    @objc func menuTapped() {
        let ableTitle: String
        dataManager.enabled() ? (ableTitle = "Disable") : (ableTitle = "Enable")

        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: ableTitle,
                                   style: .default,
                                   handler: toggleAbility))
        ac.addAction(UIAlertAction(title: "Delete",
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
        let ac = UIAlertController(title: "Delete User?",
                                   message: "Are you sure you want to delete \(dataManager.userID())",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete",
                                   style: .destructive,
                                   handler: deleteUser))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

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
        guard let tableSection = UserDataSection(rawValue: indexPath.section)
        else { return 44 }

        return tableSection.height()
    }

    func shouldHide(section: Int) -> Bool {
        guard let tableSection = UserDataSection(rawValue: section)
        else { return false }

        switch tableSection {
        case .mail: return dataManager.emailAddresses() == nil
        default: return false
        }
    }
}
