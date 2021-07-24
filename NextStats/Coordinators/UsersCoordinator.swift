//
//  UsersCoordinator.swift
//  UsersCoordinator
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import UIKit

class UsersCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func start() {
        let usersVC = UsersViewController()
        usersVC.coordinator = self

        navigationController.viewControllers = [usersVC]
        splitViewController.present(navigationController, animated: true)
    }

    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }

}
