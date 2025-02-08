//
//  InfoViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/8/20.
//  Copyright © 2021 Jon Alaniz.
//

import StoreKit
import UIKit

class InfoViewController: BaseTableViewController {
    weak var coordinator: InfoCoordinator?
    let dataManager = InfoDataManager.shared
    var products = [SKProduct]()

    override func viewDidLoad() {
        titleText = "Info"
        prefersLargeTitles = false
        tableStyle = .insetGrouped
        tableViewHeaderView = HeaderView()
        dataManager.delegate = self
        dataSource = dataManager
        delegate = self
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
    // This is called when IAP products have been gathered, only called once.
    func dataUpdated() {
        tableView.insertSections(IndexSet(integer: InfoSection.support.rawValue), with: .fade)
    }

    func controllerDidSelect(_ selection: Int, title: String) {}

    func tableViewHeightUpdated() {}
}

extension InfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let tableSection = InfoSection(rawValue: indexPath.section)
        else { return }

        let row = indexPath.row

        switch tableSection {
        case .icon: toggleIcon()
        case .licenses: coordinator?.showWebView(urlString: dataManager.licenseURLFor(row: row))
        case .support: dataManager.buyProduct(row)
        default: return
        }
    }

    private func toggleIcon() {
        dataManager.toggleIcon()
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
}
