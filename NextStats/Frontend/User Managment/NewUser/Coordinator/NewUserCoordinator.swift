//
//  NewUserCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/17/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: UsersCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigaitonController: UINavigationController
    let newUserViewController: NewUserController
    let popOverNavController = UINavigationController()

    init(splitViewController: UISplitViewController, navigationController: UINavigationController) {
        self.splitViewController = splitViewController
        self.navigaitonController = navigationController
        newUserViewController = NewUserController()
    }

    func start() {
        popOverNavController.viewControllers = [newUserViewController]
        newUserViewController.coordinator = self
        newUserViewController.tableView.dataSource = self
        navigaitonController.present(popOverNavController, animated: true)
    }

    func dismiss() {
        popOverNavController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(self)
    }
}

class NewUserFactory {
    
}
