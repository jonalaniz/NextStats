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

    let statsViewController: StatsViewController
    let serverManager = NXServerManager.shared
    let serverDataSource: ServerDataSource

    // MARK: - View Controllers

    let mainViewController: ServerViewController
    let detailNavigationController: UINavigationController
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
        let child = UsersCoordinator(
            splitViewController: splitViewController
        )
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func showStatsView(for server: NextServer) {
        if detailNavigationController.viewControllers.first != statsViewController {
            detailNavigationController.viewControllers = [statsViewController]
        }

        guard let navigationController = statsViewController.navigationController
        else { return }
        statsViewController.serverSelected(server)
        splitViewController.showDetailViewController(navigationController, sender: nil)
    }

    // MARK: - Helper Methods

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
