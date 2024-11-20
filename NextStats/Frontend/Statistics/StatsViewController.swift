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

    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let loadingView = LoadingViewController()
    let headerView = ServerHeaderView()
    let dataManager = NXStatsManager.shared
    var serverInitialized = false

    override func loadView() {
        super.loadView()
        dataManager.delegate = self
        dataManager.errorHandler = self
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
        let backgroundView = UIImageView(image: UIImage(named: "background"))
        backgroundView.layer.opacity = 0.8
        tableView.backgroundView = backgroundView

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
        tableView.register(ProgressCell.self, forCellReuseIdentifier: "MemoryCell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        add(loadingView)
        tableView.isHidden = true
    }

    func showLoadingView() {
        tableView.isHidden = true
        add(loadingView)
    }

    func showTableView() {
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
        ac.addAction(UIAlertAction(title: .localized(.statsActionDelete),
                                   style: .destructive, handler: delete))
        ac.addAction(UIAlertAction(title: .localized(.statsActionCancel),
                                   style: .cancel))
        if #available(iOS 16.0, *) {
            ac.popoverPresentationController?.sourceItem = self.navigationItem.rightBarButtonItem
        } else {
            ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        }
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
