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
    var navigationController: UINavigationController
    let newUserViewController: NewUserViewController
    let popOverNavController = UINavigationController()

    let userFactory = NXUserFactory.shared
    let newUserDataSource: NewUserDataSource

    init(splitViewController: UISplitViewController, navigationController: UINavigationController) {
        self.splitViewController = splitViewController
        self.navigationController = navigationController
        newUserViewController = NewUserViewController()
        newUserDataSource = NewUserDataSource(userFactory: userFactory)
    }

    func start() {
        userFactory.delegate = self
        popOverNavController.viewControllers = [newUserViewController]
        newUserViewController.coordinator = self
        newUserViewController.dataSource = newUserDataSource
        navigationController.present(popOverNavController, animated: true)
    }

    func dismiss() {
        popOverNavController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(self)
    }

    func showSelectionView(type: SelectionType) {
        guard let groups = userFactory.groupsAvailable() else { return }
        let selectionView: SelectionViewController
        let selections = getSelections(for: type)

        switch type {
        case .groups, .subAdmin:
            selectionView = SelectionViewController(
                data: groups,
                type: type,
                selections: selections)
        case .quota:
            selectionView = SelectionViewController(
                data: QuotaType.allCases.map(\.rawValue),
                type: .quota,
                selections: selections)
        }

        selectionView.delegate = self
        popOverNavController.pushViewController(selectionView, animated: true)
    }

    private func getSelections(for type: SelectionType) -> [String]? {
        switch type {
        case .groups: return userFactory.selectedGroupsFor(role: .member)
        case .subAdmin: return userFactory.selectedGroupsFor(role: .admin)
        case .quota: return [userFactory.quotaType().rawValue]
        }
    }

    func createUser() {
        userFactory.createUser()
    }

}
