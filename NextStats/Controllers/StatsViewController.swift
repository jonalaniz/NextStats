//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz
//

import UIKit

class StatsViewController: UIViewController {
    let loadingView = LoadingView()
    let selectServerView = SelectServerView()
    var statisticsDataManager = StatisticsDataManager.shared
    var tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
    var serverInitialized = false

    override func loadView() {
        super.loadView()
        statisticsDataManager.delegate = self
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !serverInitialized { return }
        showLoadingView()
    }

    private func setupView() {
        view.backgroundColor = .systemGroupedBackground

        // Setup our buttons
        let openInSafariButton = UIBarButtonItem(image: UIImage(systemName: "safari.fill"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(openInSafari))

        navigationItem.rightBarButtonItem = openInSafariButton

        // Setup our subviews
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(selectServerView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        selectServerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loadingView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            selectServerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            selectServerView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])

        tableView.isHidden = true
        loadingView.isHidden = true
    }

    private func showLoadingView() {
        tableView.isHidden = true
        loadingView.isHidden = false
        selectServerView.isHidden = true
    }

    private func showTableView() {
        if tableView.delegate == nil {
            tableView.delegate = self
            tableView.dataSource = self
        }

        tableView.isHidden = false
        loadingView.isHidden = true
        selectServerView.isHidden = true

        tableView.reloadData()
    }

    func serverSelected(_ newServer: NextServer) {
        // Initialize server variable with selected server
        statisticsDataManager.server = newServer
        title = statisticsDataManager.server.name
        serverInitialized = true
    }

    private func showErrorAndReturn(title: String, description: String) {
        let errorAC = UIAlertController(title: title, message: description, preferredStyle: .alert)
        errorAC.addAction(UIAlertAction(title: "Continue", style: .default, handler: self.returnToTable))

        DispatchQueue.main.async {
            self.loadingView.isHidden = true
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
    func willBeginFetchingData() {
        showLoadingView()
    }

    func failedToUpdateData(error: DataManagerError) {
        switch error {
        case .unableToParseJSON:
            self.showErrorAndReturn(title: "Error", description: error.description)
        case .missingData:
            self.showErrorAndReturn(title: "Error", description: error.description)
        }
    }

    func failedToFetchData(error: FetchError) {
        switch error {
        case .network(let networkError):
            self.showErrorAndReturn(title: error.title,
                                    description: "\(networkError.localizedDescription)")
        case .unexpectedResponse(let response):
            switch response {
            case 401:
                self.showErrorAndReturn(title: error.title + ": \(response)",
                                        description: LocalizedKeys.errorUnauthorizedDescription)
            default:
                self.showErrorAndReturn(title: error.title + ": (\(response))",
                                        description: "\(response)")
            }
        default:
            self.showErrorAndReturn(title: error.title, description: error.description)
        }
    }

    func dataUpdated() {
        showTableView()
    }
}
