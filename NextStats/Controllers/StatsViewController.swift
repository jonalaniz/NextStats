//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
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

}

// MARK: Functions
extension StatsViewController {
    private func setupView() {
        // Add Activity Indicator and Open in Safari Button
        let activityIndicatorBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        let openInSafariButton = UIBarButtonItem(image: UIImage(systemName: "safari.fill"), style: .plain, target: self, action: #selector(openInSafari))

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

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        navigationController?.isNavigationBarHidden = false

        viewInitialized = true
    }

    private func displayErrorAndReturn(title: String, description: String) {
        let ac = UIAlertController(title: title, message: description, preferredStyle: .alert)
        self.activityIndicator.deactivate()
        self.tableView.isHidden = true

        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: self.returnToTable))

        // This function is typically called from network tasks in the StatisticsDataManager
        DispatchQueue.main.async {
            self.present(ac, animated: true)
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

// MARK: ServerSelectionDelegate
extension StatsViewController {
    func serverSelected(_ newServer: NextServer) {
        // Initialize server variable with selected server
        statisticsDataManager.server = newServer

        // Unhide UI and set Title
        navigationController?.isNavigationBarHidden = false
        setupTableView()
        tableView.isHidden = false
        title = statisticsDataManager.server.name
        activityIndicator.activate()
    }
}

// MARK: StatisticsDataManagerDelegate
extension StatsViewController: StatisticsDataManagerDelegate {
    func fetchingDidBegin() {
        // this is possibly not needed
    }

    func errorFetchingData(error: FetchError) {
        switch error {
        case .invalidData:
            self.displayErrorAndReturn(title: "Invalid Data", description: "Server response data could not be read.")
        case .missingResponse:
            self.displayErrorAndReturn(title: "Missing Response", description: "Server could be reached, but response was not given.")
        case .network(let error):
            self.displayErrorAndReturn(title: "Network Error", description: "\(error.localizedDescription)")
        case .unexpectedResponse(let response):
            switch response {
            case 401:
                self.displayErrorAndReturn(title: "Unauthorized (\(response))", description: "User must have administrative privileges to fetch server statistics.")
            default:
                self.displayErrorAndReturn(title: "Unexpected Response (\(response))", description: "\(response)")
            }
        }

        print("Error fetching data \(error)")
    }

    func dataUpdated() {
        activityIndicator.deactivate()
        tableView.reloadData()
    }

    func errorUpdatingData() {
        self.displayErrorAndReturn(title: "Error updating data.", description: "Statistics data missing from server response.")
    }
}
