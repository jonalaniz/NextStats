//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

// swiftlint:disable identifier_name
class StatsViewController: BaseTableViewController {
    weak var coordinator: MainCoordinator?

    let loadingView = LoadingViewController()
    let headerView = ServerHeaderView()
    let dataManager = NXStatsManager.shared
    var serverInitialized = false

    override func viewDidLoad() {
        tableStyle = .insetGrouped
        super.viewDidLoad()
        dataManager.delegate = self
        dataManager.errorHandler = self

        add(loadingView)
        tableView.isHidden = true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(reload) || action == #selector(openInSafari) {
            return serverInitialized
        }

        return super.canPerformAction(action, withSender: sender)
    }

    override func setupNavigationController() {
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(menuTapped))

        navigationItem.rightBarButtonItem = moreButton
        navigationItem.largeTitleDisplayMode = .never

        if isMacCatalyst() {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    override func registerCells() {
        tableView.register(ProgressCell.self, forCellReuseIdentifier: "MemoryCell")
    }

    func showLoadingView() {
        tableView.isHidden = true
        add(loadingView)
    }

    func showTableView() {
        if tableView.delegate == nil {
            tableView.delegate = self
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
        tableViewHeaderView = headerView
    }

    @objc func openInSafari() {
        guard serverInitialized else { return }

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

extension StatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StatsSection(rawValue: indexPath.section)?.rowHeight ?? 0
    }
}
