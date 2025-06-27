//
//  UsersCoordinator.swift
//  UsersCoordinator
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Coordinator responsible for managing and viewing users.
class UsersCoordinator: NSObject, Coordinator {
    // MARK: - Coordinator

    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()

    // MARK: - Dependencies

    let formatter = NXUserFormatter.shared
    let usersManager = NXUsersManager.shared
    let userFactory = NXUserFactory.shared

    // MARK: - View Controllers

    let usersViewController: UsersViewController
    let usersDataSource: UsersDataSource
    let userViewController: UserViewController
    private let userDataSource: UserDataSource
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    // MARK: - Initialization

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        usersViewController = UsersViewController()
        usersDataSource = UsersDataSource(usersManager: usersManager)
        userViewController = UserViewController()
        userDataSource = UserDataSource(formatter: formatter)
    }

    // MARK: - Coordinator Lifecycle

    func start() {
        usersViewController.coordinator = self
        usersViewController.dataSource = usersDataSource
        usersManager.delegate = self
        usersManager.errorHandler = self
        navigationController.viewControllers = [usersViewController]

        splitViewController.present(
            navigationController,
            animated: true
        )
        userFactory.getGroups(for: usersManager.server)
    }

    func showAddUserView() {
        let child = NewUserCoordinator(
            splitViewController: splitViewController,
            navigationController: navigationController
        )
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func showUserView(for user: User) {
        userViewController.coordinator = self
        userViewController.dataManager.set(user)
        userViewController.dataSource = userDataSource
        navigationController.pushViewController(userViewController, animated: true)
    }

    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
        }
    }

    func didFinish() {
        guard
            let detailNavigationController = parentCoordinator?.detailNavigationController
        else { return }

        for (index, viewController) in detailNavigationController.viewControllers.enumerated()
        where viewController === userViewController || viewController === usersViewController {
            detailNavigationController.viewControllers.remove(at: index)
        }

        parentCoordinator?.childDidFinish(self)
    }

    // MARK: - Actions

    func set(_ server: NextServer) {
        usersManager.setServer(server: server)
    }

    func updateUsers() {
        usersViewController.toggleLoadingState(isLoading: true)
        usersManager.fetchUsersData()
    }

    func delete(user: String) {
        usersManager.delete(user: user)
    }

    func toggle(user: String) {
        usersManager.toggle(user: user)
    }
}
