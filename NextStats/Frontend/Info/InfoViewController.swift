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

    var infoModel = InfoModel()
    var products = [SKProduct]()
    let tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkForProducts()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(thank),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
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

        // Connect the TableView to ViewController
        tableView.delegate = self
        tableView.dataSource = self

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

// MARK: TableView Functions
extension InfoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return infoModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return products.count
        }

        return infoModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        var content = cell.defaultContentConfiguration()

        // Custom Cell Setup
        switch indexPath.section {
        case 2:
            // License Section
            cell.accessoryType = .disclosureIndicator
            content.text = infoModel.titleLabelFor(row: indexPath.row, section: indexPath.section)
            content.secondaryText = infoModel.detailLabelFor(row: indexPath.row, section: indexPath.section)
        case 3:
            // IAP Section
            // Get product
            let product = products[indexPath.row]

            // Setup currency
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale

            let cost = formatter.string(from: product.price)

            // Setup cell
            content.text = product.localizedTitle
            content.secondaryText = cost
        default:
            cell.selectionStyle = .none
            content.text = infoModel.titleLabelFor(row: indexPath.row, section: indexPath.section)
            content.secondaryText = infoModel.detailLabelFor(row: indexPath.row, section: indexPath.section)
        }

        content.textProperties.color = .theme
        cell.contentConfiguration = content

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return infoModel.title(for: section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return infoModel.footer(for: section)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 2:
            // Show proper license information
            coordinator?.showWebView(urlString: infoModel.licenseURLFor(row: indexPath.row))
        case 3:
            // IAP Selection
            NextStatsProducts.store.buyProduct(products[indexPath.row])
        default:
            return
        }
    }
}

// MARK: IAP Functions
extension InfoViewController {
    func checkForProducts() {
        // First check if user can make payments
        if IAPHelper.canMakePayments() == false { return }

        // If products can be reached, insert the IAP Section into the TableView
        NextStatsProducts.store.requestProducts { [self] success, products in
            if success {
                if let unwrappedProducts = products {
                    DispatchQueue.main.async {
                        self.products = unwrappedProducts
                        self.infoModel.enableIAP()
                        self.tableView.insertSections(IndexSet(integer: 3), with: .fade)
                    }
                }
            }
        }
    }
}
