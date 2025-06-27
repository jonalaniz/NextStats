//
//  MainCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Main Coordinator  responsible for selecting, editing, and viewing servers.
class MainCoordinator: NSObject, Coordinator {
    // MARK: - Coordinator

    var childCoordinators = [Coordinator]()

    // MARK: - Dependencies

    let serverManager = NXServerManager.shared
    let serverDataSource: ServerDataSource
    let statsDataManager = NXStatsManager.shared

    // MARK: - View Controllers

    let mainViewController: ServerViewController
    let detailNavigationController: UINavigationController
    let statsViewController: StatsViewController
    var splitViewController: UISplitViewController

    // MARK: - Initialization

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController

        mainViewController = ServerViewController()
        statsViewController = StatsViewController()
        detailNavigationController = UINavigationController(
            rootViewController: SelectServerViewController()
        )
        serverDataSource = ServerDataSource(
            serverManager: serverManager
        )
    }

    // MARK: - Coordinator Lifecycle

    // This is where we initialize the UISplitViewController
    func start() {
        // Initialize our SplitView
        let mainNavigationController = UINavigationController(
            rootViewController: mainViewController
        )

        splitViewController.viewControllers = [
            mainNavigationController,
            detailNavigationController
        ]
        mainViewController.coordinator = self
        mainViewController.dataSource = serverDataSource
        statsViewController.coordinator = self
        statsDataManager.delegate = self
        statsDataManager.errorHandler = self
    }

    // MARK: - Navigation

    func showAddServerView() {
        let child = AddServerCoordinator(
            splitViewController: splitViewController
        )
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func showInfoView() {
        let child = InfoCoordinator(
            splitViewController: splitViewController
        )
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func showUsersView() {
        guard let server = statsDataManager.server
        else { return }

        let child = UsersCoordinator(
            splitViewController: splitViewController
        )
        child.parentCoordinator = self
        child.set(server)
        childCoordinators.append(child)
        child.start()
    }

    func showStatsView(for server: NextServer) {
        if detailNavigationController.viewControllers.first != statsViewController {
            detailNavigationController.viewControllers = [statsViewController]
        }

        guard let navigationController = statsViewController.navigationController
        else { return }
        statsDataManager.server = server
        statsViewController.updateUIFor(server)
        splitViewController.showDetailViewController(navigationController, sender: nil)
    }

    // MARK: - Server Manager Methods
    func checkWipeStatus() {
        guard let server  = statsDataManager.server
        else { return }
        serverManager.checkWipeStatus(server: server)
    }

    func delete() {
        guard let server = statsDataManager.server
        else { return }
        serverManager.remove(server, refresh: true)
    }

    func reload() {
        statsDataManager.reload()
    }

    func rename(_ name: String) {
        guard let server = statsDataManager.server
        else { return }
        serverManager.renameServer(server, to: name) { newServer in
            statsDataManager.server = newServer
        }
    }

    // MARK: - Mac Catalyst actions

    @objc func addServerClicked() {
        showAddServerView()
    }

    @objc func menuClicked() {
        guard statsDataManager.server != nil else { return }
        statsViewController.menuTapped()
    }

    // MARK: - Helper Methods

    func openInSafari() {
        guard
            let urlString = statsDataManager.server?.friendlyURL,
            let url = URL(string: urlString)
        else { return }
        UIApplication.shared.open(url)
    }

    /// Destroy the addServerCoordinator object and refresh the ServerViewController
    func addServer(_ server: NextServer) {
        serverManager.add(server)
        mainViewController.refresh()
    }

    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
        }
    }
}

extension MainCoordinator: NXDataManagerDelegate {
    func stateDidChange(_ state: NXDataManagerState) {
        switch state {
        case .fetchingData:
            statsViewController.showLoadingView()
        case .dataCaptured(let sections):
            statsViewController.updateDataSource(with: sections)
        }
    }
}

extension MainCoordinator: ErrorHandling {
    func handleError(_ error: APIManagerError) {
        // fuck piss and shit
    }
}
