//
//  InfoViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/8/20.
//  Copyright © 2021 Jon Alaniz.
//

import StoreKit
import UIKit

// swiftlint:disable weak_delegate
class InfoViewController: BaseTableViewController {
    // MARK: - Properties

    private let dataManager = InfoDataManager.shared

    weak var coordinator: InfoCoordinator?
    private var products = [SKProduct]()
    private var tableDelegate: InfoTableViewDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        titleText = "Info"
        prefersLargeTitles = false
        tableStyle = .insetGrouped
        tableViewHeaderView = InfoHeaderView()
        dataManager.delegate = self
        dataSource = dataManager
        tableDelegate = InfoTableViewDelegate(
            coordinator: coordinator,
            dataManager: dataManager
        )
        delegate = tableDelegate
        super.viewDidLoad()
        setupNotifications()
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
