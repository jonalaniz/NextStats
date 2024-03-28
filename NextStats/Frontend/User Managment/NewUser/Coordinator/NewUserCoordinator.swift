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

    let userFactory = NXUserFactory.shared

    init(splitViewController: UISplitViewController, navigationController: UINavigationController) {
        self.splitViewController = splitViewController
        self.navigaitonController = navigationController
        newUserViewController = NewUserController()
    }

    func start() {
        userFactory.delegate = self
        popOverNavController.viewControllers = [newUserViewController]
        newUserViewController.coordinator = self
        newUserViewController.tableView.dataSource = self
        newUserViewController.tableView.delegate = self
        navigaitonController.present(popOverNavController, animated: true)
    }

    func dismiss() {
        popOverNavController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(self)
    }

    func showSelectionView(type: SelectionType) {
        guard let groups = userFactory.groupsAvailable() else { return }
        let selectionView: SelectionViewController

        switch type {
        case .groups: selectionView = SelectionViewController(data: groups, type: .groups)
        case .subAdmin: selectionView = SelectionViewController(data: groups, type: .subAdmin)
        case .quota:
            let array = QuotaType.allCases.map { $0.rawValue }
            selectionView = SelectionViewController(data: array, type: .quota)
            selectionView.selections.insert(userFactory.quotaType().rawValue)
        }

        selectionView.delegate = self
        popOverNavController.pushViewController(selectionView, animated: true)
    }

    func createUser() {
        userFactory.createUser()
    }
}
