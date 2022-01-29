//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import UIKit

class StatsViewController: UIViewController {
    weak var coordinator: MainCoordinator?

    let loadingView = LoadingViewController()
    let headerView = ServerHeaderView()
    var nextStatsDataManager = NextStatsDataManager.shared
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    var serverInitialized = false

    override func loadView() {
        super.loadView()
        nextStatsDataManager.delegate = self
        setupView()
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(reload) || action == #selector(openInSafari) {
            return serverInitialized
        }

        return super.canPerformAction(action, withSender: sender)
    }

    private func setupView() {
        view.backgroundColor = .systemGroupedBackground

        // Setup our buttons
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(menuTapped))

        navigationItem.rightBarButtonItem = moreButton
        navigationItem.largeTitleDisplayMode = .never

        #if targetEnvironment(macCatalyst)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        #endif

        // Setup our subviews
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        add(loadingView)
        tableView.isHidden = true
    }

    private func showLoadingView() {
        tableView.isHidden = true
        add(loadingView)
    }

    private func showTableView() {
        if tableView.delegate == nil {
            tableView.delegate = nextStatsDataManager
            tableView.dataSource = nextStatsDataManager
        }

        tableView.isHidden = false
        loadingView.remove()
        tableView.reloadData()
    }

    /// Initializes server variable with selected server and updates UI
    func serverSelected(_ newServer: NextServer) {
        nextStatsDataManager.server = newServer
        serverInitialized = true

        let headerView = ServerHeaderView()
        headerView.setupHeaderWith(name: newServer.name, address: newServer.friendlyURL, image: newServer.serverImage())
        headerView.userManagementButton.addTarget(self,
                                                  action: #selector(userManagementPressed),
                                                  for: .touchUpInside)
        headerView.openInBrowserButton.addTarget(self,
                                                 action: #selector(openInSafari), for: .touchUpInside)
        tableView.tableHeaderView = headerView
    }

    private func showErrorAndReturn(title: String, description: String) {
        let errorAC = UIAlertController(title: title, message: description, preferredStyle: .alert)
        errorAC.addAction(UIAlertAction(title: "Continue", style: .default, handler: self.returnToTable))

        DispatchQueue.main.async {
            self.loadingView.remove()
            self.tableView.isHidden = true
            self.present(errorAC, animated: true)
        }
    }

    private func returnToTable(action: UIAlertAction! = nil) {
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }

    @objc func openInSafari() {
        guard serverInitialized != false else { return }

        let urlString = nextStatsDataManager.server!.friendlyURL.addIPPrefix()
        let url = URL(string: urlString)!
        UIApplication.shared.open(url)
    }

    @objc func menuTapped() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Change Name", style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "Refresh Icon", style: .default, handler: nil))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: nil))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }

    @objc func reload() {
        if !serverInitialized { return }
        nextStatsDataManager.reload()
    }

    @objc func userManagementPressed() {
        guard serverInitialized != false else { return }
        let userDataManager = UserDataManager.shared
        userDataManager.setServer(server: nextStatsDataManager.server!)

        coordinator?.showUsersView()
    }
}

// MARK: NextStatsDataManagerDelegate
extension StatsViewController: NextDataManagerDelegate {
    func stateDidChange(_ dataManagerState: NSDataManagerState) {
        switch dataManagerState {
        case .fetchingData:
            showLoadingView()
        case .parsingData:
            print("Parsing Data")
        case .failed(let nextDataManagerError):
            switch nextDataManagerError {
            case .networkError(let error):
                handleNetworkError(error)
            case .unableToDecode:
                self.showErrorAndReturn(title: "Error", description: nextDataManagerError.description)
            case .missingData:
                self.showErrorAndReturn(title: "Error", description: nextDataManagerError.description)
            }
        case .statsCaptured:
            showTableView()
        }
    }

    func handleNetworkError(_ error: FetchError) {
        switch error {
        case .invalidData:
            self.showErrorAndReturn(title: error.title, description: error.description)
        case .missingResponse:
            self.showErrorAndReturn(title: error.title, description: error.description)
        case .network(let networkError):
            self.showErrorAndReturn(title: error.title, description: networkError.localizedDescription)
        case .unexpectedResponse(let response):
            switch response {
            case 401:
                self.showErrorAndReturn(title: error.title + ": \(response)",
                                        description: .localized(.unauthorizedDescription))
            default:
                self.showErrorAndReturn(title: error.title + ": (\(response))",
                                        description: "\(response)")
            }
        }
    }
}
