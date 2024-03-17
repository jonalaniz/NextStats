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

    init(splitViewController: UISplitViewController, navigationController: UINavigationController) {
        self.splitViewController = splitViewController
        self.navigaitonController = navigationController
        newUserViewController = NewUserController()
        newUserViewController.coordinatpr = self
    }

    func start() {
        let popOverNavController = UINavigationController()
        popOverNavController.viewControllers = [newUserViewController]
        navigaitonController.present(popOverNavController, animated: true)
    }

}

class NewUserFactory {
    
}
