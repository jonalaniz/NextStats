//
//  UsersCoordinator.swift
//  UsersCoordinator
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class UsersCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    let usersViewController: UsersViewController
    let userViewController: UserViewController

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        usersViewController = UsersViewController()
        userViewController = UserViewController()

        usersViewController.coordinator = self
        usersViewController.usersDataManager.delegate = usersViewController
    }

    func start() {
        navigationController.viewControllers = [usersViewController]

        splitViewController.present(navigationController, animated: true)
    }

    func showAddUserView() {
        let newUserController = NewUserController()
        navigationController.pushViewController(newUserController, animated: true)
    }

    func showUserView(for user: User) {
        userViewController.userDataManager.set(user)
        userViewController.setupView()
        navigationController.pushViewController(userViewController, animated: true)
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
