//
//  InfoViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/8/20.
//  Copyright © 2021 Jon Alaniz.
//

import StoreKit
import UIKit

class InfoViewController: UIViewController {
    weak var coordinator: InfoCoordinator?
    var products = [SKProduct]()
    let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        NotificationCenter.default.addObserver(forName: .IAPHelperPurchaseNotification,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            self?.thank()
        }
    }

    private func setupView() {
        // Setup Navigation Bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissController))
        title = "Info"

        // Setup View
        view.backgroundColor = .systemBackground

        // Setup TableViewHeader
        tableView.tableHeaderView = HeaderView()
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
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
}
