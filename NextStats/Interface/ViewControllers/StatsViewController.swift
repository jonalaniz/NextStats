//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class StatsViewController: BaseDataTableViewController {
    weak var coordinator: MainCoordinator?

    let loadingView = LoadingViewController()
    let headerView = ServerHeaderView()

    var serverInitialized = false

    override func viewDidLoad() {
        delegate = self
        dataSource = StatisticsDataSource()
        tableStyle = .insetGrouped
        super.viewDidLoad()

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
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(menuTapped)
        )

        navigationItem.rightBarButtonItem = moreButton
        navigationItem.largeTitleDisplayMode = .never

        if isMacCatalyst() {
            self.navigationController?.setNavigationBarHidden(
                true, animated: true
            )
        }
    }

    override func registerCells() {
        tableView.register(
            ProgressCell.self,
            forCellReuseIdentifier: ProgressCell.reuseIdentifier
        )
    }

    func showLoadingView() {
        guard let tableView = tableView else { return }
        tableView.isHidden = true
        add(loadingView)
    }

    func showTableView() {
        tableView.isHidden = false
        loadingView.remove()
        tableView.reloadData()
    }

    /// Initializes server variable with selected server and updates UI
    func serverSelected(_ newServer: NextServer) {
        // This is currently called from the MainCoordinator.
        // We need to decouple the DataManager from the ViewController
        headerView.setupHeaderWith(
            name: newServer.name,
            address: newServer.friendlyURL,
            image: newServer.serverImage())
        headerView.users.addTarget(
            self,
            action: #selector(userManagementPressed),
            for: .touchUpInside
        )
        headerView.visitServerButton.addTarget(
            self,
            action: #selector(openInSafari),
            for: .touchUpInside
        )
        tableViewHeaderView = headerView
    }

    @objc func openInSafari() {
        coordinator?.openInSafari()
    }

    @objc func menuTapped() {
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        alertController.addAction(
            UIAlertAction(
                title: .localized(.statsActionRename),
                style: .default,
                handler: showRenameSheet)
        )
        alertController.addAction(
            UIAlertAction(
                title: .localized(.statsActionDelete),
                style: .destructive,
                handler: delete)
        )
        alertController.addAction(
            UIAlertAction(
                title: .localized(.statsActionCancel),
                style: .cancel)
        )

        if #available(iOS 16.0, *) {
            alertController.popoverPresentationController?.sourceItem = self.navigationItem.rightBarButtonItem
        } else {
            alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        present(alertController, animated: true)
    }

    @objc func reload() {
        coordinator?.reload()
    }

    @objc func userManagementPressed() {
        coordinator?.showUsersView()
    }

    func updateDataSource(with sections: [TableSection]) {
        dataSource.sections = sections
        showTableView()
    }
}

// MARK: - UITableViewDelegate

extension StatsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return StatsSection(
            rawValue: indexPath.section
        )?.rowHeight ?? 0
    }
}
