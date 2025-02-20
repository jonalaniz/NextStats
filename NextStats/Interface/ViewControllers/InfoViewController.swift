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
    weak var coordinator: InfoCoordinator?
    let dataManager = InfoDataManager.shared
    private var tableDelegate: InfoTableViewDelegate?
    var products = [SKProduct]()

    override func viewDidLoad() {
        titleText = "Info"
        prefersLargeTitles = false
        tableStyle = .insetGrouped
        tableViewHeaderView = InfoHeaderView()
        dataManager.delegate = self
        dataSource = dataManager
        tableDelegate = InfoTableViewDelegate(coordinator: coordinator, dataManager: dataManager)
        delegate = tableDelegate
        super.viewDidLoad()
        setupNotifications()
    }

    override func setupNavigationController() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissController))
    }

    @objc func dismissController() {
        coordinator?.didFinish()
        dismiss(animated: true, completion: nil)
    }

    @objc func thank() {
        let thankAC = UIAlertController(title: .localized(.iapThank),
                                        message: .localized(.iapThankDescription),
                                        preferredStyle: .alert)
        thankAC.addAction((UIAlertAction(title: "Continue",
                                         style: .default,
                                         handler: nil)))
        present(thankAC, animated: true)
    }

    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(thank),
                                       name: .IAPHelperPurchaseNotification,
                                       object: nil)
    }
}

extension InfoViewController: DataManagerDelegate {
    func stateDidChange(_ state: DataManagerStatus) {
        print("StateDidChange: \(state)")
        switch state {
        case .dataUpdated: tableView.reloadData()
        default: break
        }
    }
}
