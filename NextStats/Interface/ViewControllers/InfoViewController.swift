//
//  InfoViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/8/20.
//  Copyright © 2021 Jon Alaniz.
//

import StoreKit
import UIKit

final class InfoViewController: BaseTableViewController {
    // MARK: - Coordinator

    weak var coordinator: InfoCoordinator?

    // MARK: - Properties

    private let dataManager = InfoDataManager.shared
    private var products = [SKProduct]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        titleText = "Info"
        prefersLargeTitles = false
        tableStyle = .insetGrouped
        tableViewHeaderView = InfoHeaderView()
        dataManager.delegate = self
        delegate = self
        super.viewDidLoad()
        setupNotifications()
        tableView.dataSource = dataManager
    }

    // MARK: - Configuration

    override func setupNavigationController() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissController))
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(thank),
            name: .IAPHelperPurchaseNotification,
            object: nil
        )
    }

    // MARK: - Actions

    @objc private func dismissController() {
        coordinator?.didFinish()
        dismiss(animated: true, completion: nil)
    }

    @objc private func thank() {
        let thankAC = UIAlertController(
            title: .localized(.iapThank),
            message: .localized(.iapThankDescription),
            preferredStyle: .alert
        )
        thankAC.addAction((UIAlertAction(
            title: "Continue",
            style: .default,
            handler: nil))
        )
        present(thankAC, animated: true)
    }
}

// MARK: - DataManagerDelegate

extension InfoViewController: DataManagerDelegate {
    func stateDidChange(_ state: DataManagerStatus) {
        switch state {
        case .dataUpdated: tableView.reloadData()
        default: break
        }
    }
}

// MARK: - UITableViewDelegate
extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let tableSection = InfoSection(rawValue: indexPath.section)
        else { return }

        let row = indexPath.row

        switch tableSection {
        case .icon: dataManager.toggleIcon()
        case .licenses:
            guard let license = License(rawValue: row) else { return }
            coordinator?.showWebView(urlString: license.urlString)
        case .support: dataManager.buyProduct(row)
        default: return
        }
    }
}
