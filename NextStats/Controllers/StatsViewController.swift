//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz
//

import UIKit

class StatsViewController: UIViewController {
    var statisticsDataManager = StatisticsDataManager.shared
    var tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
    var viewInitialized = false

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

    override func loadView() {
        super.loadView()
        statisticsDataManager.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemGroupedBackground

        let activityIndicatorBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        let openInSafariButton = UIBarButtonItem(image: UIImage(systemName: "safari.fill"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(openInSafari))

        navigationItem.rightBarButtonItems = [openInSafariButton, activityIndicatorBarButtonItem]

        if !viewInitialized { navigationController?.isNavigationBarHidden = true }
    }

    private func setupTableView() {
        if viewInitialized { return }

        // Initialize and connect the tableView
        tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self

        // Constrain tableView
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        viewInitialized = true
        navigationController?.isNavigationBarHidden = false
    }

    func serverSelected(_ newServer: NextServer) {
        // Initialize server variable with selected server
        statisticsDataManager.server = newServer

        // Unhide UI and set Title
        setupTableView()
        tableView.isHidden = false
        title = statisticsDataManager.server.name
    }

    private func displayErrorAndReturn(title: String, description: String) {
        let errorAC = UIAlertController(title: title, message: description, preferredStyle: .alert)
        errorAC.addAction(UIAlertAction(title: "Continue", style: .default, handler: self.returnToTable))

        DispatchQueue.main.async {
            self.activityIndicator.deactivate()
            self.tableView.isHidden = true
            self.present(errorAC, animated: true)
        }
    }

    private func returnToTable(action: UIAlertAction! = nil) {
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }

    @objc func openInSafari() {
        let urlString = statisticsDataManager.server.friendlyURL.addIPPrefix()
        let url = URL(string: urlString)!
        UIApplication.shared.open(url)
    }

}

// MARK: Table View Functions
extension StatsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return statisticsDataManager.sections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statisticsDataManager.rows(in: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return statisticsDataManager.sectionLabel(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let section = indexPath.section
        let row = indexPath.row

        cell.textLabel?.text = statisticsDataManager.rowLabel(forRow: row, inSection: section)
        cell.detailTextLabel?.text = statisticsDataManager.rowData(forRow: row, inSection: section)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }

}

// MARK: StatisticsDataManagerDelegate
extension StatsViewController: StatisticsDataManagerDelegate {
    func failedToUpdateData(error: DataManagerError) {
        switch error {
        case .unableToParseJSON:
            self.displayErrorAndReturn(title: "Error", description: error.description)
        case .missingData:
            self.displayErrorAndReturn(title: "Error", description: error.description)
        }
    }

    func willBeginFetchingData() {
        activityIndicator.startAnimating()
    }

    func failedToFetchData(error: FetchError) {
        switch error {
        case .invalidData:
            self.displayErrorAndReturn(title: "Invalid Data".localized(),
                                       description: "Invalid Data Description".localized())
        case .missingResponse:
            self.displayErrorAndReturn(title: "Missing Response".localized(),
                                       description: "Missing Response Description".localized())
        case .network(let error):
            self.displayErrorAndReturn(title: "Network Error".localized(),
                                       description: "\(error.localizedDescription)")
        case .unexpectedResponse(let response):
            switch response {
            case 401:
                self.displayErrorAndReturn(title: "Unauthorized".localized() + ": \(response)",
                                           description: "Unauthorized Description".localized())
            default:
                self.displayErrorAndReturn(title: "Unexpected Response".localized() + ": (\(response))",
                                           description: "\(response)")
            }
        }
    }

    func dataUpdated() {
        activityIndicator.deactivate()
        tableView.reloadData()
    }

    func failedToUpdateData() {
        self.displayErrorAndReturn(title: "Invalid Data".localized(),
                                   description: "Invalid Data Description".localized())
    }
}
