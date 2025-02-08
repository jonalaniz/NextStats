//
//  UsersCoordinator.swift
//  UsersCoordinator
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class UsersCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: MainCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    let formatter = NXUserFormatter.shared
    let usersManager = NXUsersManager.shared
    let usersViewController: UsersViewController
    let userViewController: UserViewController

    let newUserController = NXUserFactory.shared

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        usersViewController = UsersViewController()
        userViewController = UserViewController()
    }

    func start() {
        usersViewController.coordinator = self
        usersManager.delegate = self
        usersManager.errorHandler = self
        navigationController.viewControllers = [usersViewController]

        splitViewController.present(navigationController, animated: true)
        newUserController.getGroups(for: usersManager.server)
    }

    func showAddUserView() {
        let child = NewUserCoordinator(splitViewController: splitViewController,
                                       navigationController: navigationController)
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func showUserView(for user: User) {
        userViewController.coordinator = self
        userViewController.dataManager.set(user)
        userViewController.dataSource = self
        userViewController.setupView()
        navigationController.pushViewController(userViewController, animated: true)
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
}
