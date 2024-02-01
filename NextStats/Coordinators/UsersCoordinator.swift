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

        navigationController.viewControllers = [usersViewController]
        splitViewController.showDetailViewController(navigationController, sender: nil)
    }

    func showUserView(for user: User) {
        // Ensure that we are grabbing the proper viewController
        guard let navigationController = usersViewController.navigationController else { return }

        userViewController.userDataManager.set(user)
        userViewController.setupView()
        splitViewController.showDetailViewController(userViewController, sender: nil)
    }

    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }

}
