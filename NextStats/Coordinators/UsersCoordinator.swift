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

        usersViewController.usersDataManager.delegate = usersViewController
    }

    func start() {
        usersViewController.coordinator = self

        guard let detailNavigationController = parentCoordinator?.detailNavigationController else { return }

        detailNavigationController.pushViewController(usersViewController, animated: true)
    }

    func showUserView(for user: User) {
        // Ensure that we are grabbing the proper viewController
        guard let detailNavigationController = parentCoordinator?.detailNavigationController else { return }

        userViewController.userDataManager.set(user)
        userViewController.setupView()
        detailNavigationController.pushViewController(userViewController, animated: true)
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
