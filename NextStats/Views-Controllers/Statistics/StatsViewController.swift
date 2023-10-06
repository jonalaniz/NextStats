//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

// swiftlint:disable identifier_name
class StatsViewController: UIViewController {
    weak var coordinator: MainCoordinator?

    let loadingView = LoadingViewController()
    let headerView = ServerHeaderView()
    var dataManager = NXStatsManager.shared
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    var serverInitialized = false

    override func loadView() {
        super.loadView()
        dataManager.delegate = self
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
            tableView.delegate = dataManager
            tableView.dataSource = dataManager
        }

        tableView.isHidden = false
        loadingView.remove()
        tableView.reloadData()
    }

    /// Initializes server variable with selected server and updates UI
    func serverSelected(_ newServer: NextServer) {
        dataManager.server = newServer
        serverInitialized = true

        headerView.setupHeaderWith(name: newServer.name,
                                   address: newServer.friendlyURL,
                                   image: newServer.serverImage())
        headerView.users.addTarget(self,
                                   action: #selector(userManagementPressed),
                                   for: .touchUpInside)
        headerView.visitServerButton.addTarget(self,
                                               action: #selector(openInSafari),
                                               for: .touchUpInside)
        tableView.tableHeaderView = headerView
    }

    private func showErrorAndReturn(title: String, description: String) {
        let errorAC = UIAlertController(title: title,
                                        message: description,
                                        preferredStyle: .alert)
        errorAC.addAction(UIAlertAction(title: .localized(.statsActionContinue),
                                        style: .default,
                                        handler: self.returnToTable))

        DispatchQueue.main.async {
            self.loadingView.remove()
            self.tableView.isHidden = true
            self.present(errorAC, animated: true)
        }
    }

    func returnToTable(action: UIAlertAction! = nil) {
        tableView.isHidden = true
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }

    @objc func openInSafari() {
        guard serverInitialized != false else { return }

        var urlString = dataManager.server!.friendlyURL
        urlString.addIPPrefix()
        let url = URL(string: urlString)!
        UIApplication.shared.open(url)
    }

    @objc func menuTapped() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: .localized(.statsActionRename),
                                   style: .default, handler: showRenameSheet))
//        ac.addAction(UIAlertAction(title: "Update Icon",
//                                   style: .default,
//                                   handler: refreshIcon))
        ac.addAction(UIAlertAction(title: .localized(.statsActionDelete),
                                   style: .destructive, handler: delete))
        ac.addAction(UIAlertAction(title: .localized(.statsActionCancel),
                                   style: .cancel))
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }

    @objc func reload() {
        if !serverInitialized { return }
        dataManager.reload()
    }

    @objc func userManagementPressed() {
        guard serverInitialized != false else { return }
        let userDataManager = NXUsersManager.shared
        userDataManager.setServer(server: dataManager.server!)

        coordinator?.showUsersView()
    }
}

// MARK: NextStatsDataManagerDelegate
extension StatsViewController: NXDataManagerDelegate {
    func stateDidChange(_ dataManagerState: NXDataManagerState) {
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
                self.showErrorAndReturn(title: .localized(.errorTitle),
                                        description: nextDataManagerError.description)
            case .missingData:
                self.showErrorAndReturn(title: .localized(.errorTitle),
                                        description: nextDataManagerError.description)
            }
        case .dataCaptured:
            showTableView()
        }
    }

    func handleNetworkError(_ error: FetchError) {
        switch error {
        case .error(let err):
            showErrorAndReturn(title: .localized(.errorTitle), description: err)
        case .invalidData:
            self.showErrorAndReturn(title: error.title,
                                    description: error.description)
        case .invalidURL:
            showErrorAndReturn(title: .localized(.errorTitle), description: .localized(.notValidhost))
        case .missingResponse:
            showErrorAndReturn(title: .localized(.missingResponse),
                               description: .localized(.missingResponseDescription))
        case .unexpectedResponse(let response):
            switch response.statusCode {
            case 401:
                showErrorAndReturn(title: error.title + ": \(response.statusCode)",
                                   description: .localized(.unauthorizedDescription))
            default:
                showErrorAndReturn(title: error.title + ": \(response.statusCode)",
                                   description: response.description)
            }
        }
    }
}
