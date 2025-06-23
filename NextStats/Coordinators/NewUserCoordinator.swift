//
//  NewUserCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/17/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit
/// Coordinator responsible for managing the flow of creating a new user..
final class NewUserCoordinator: NSObject, Coordinator {
    // MARK: - Coordinator

    weak var parentCoordinator: UsersCoordinator?
    var childCoordinators = [Coordinator]()

    // MARK: - Dependencies

    let userFactory = NXUserFactory.shared
    private let newUserDataSource: NewUserDataSource

    // MARK: - View Controllers

    let newUserViewController: NewUserViewController
    let popOverNavController = UINavigationController()
    private let navigationController: UINavigationController
    var splitViewController: UISplitViewController

    // MARK: - Initialization

    init(splitViewController: UISplitViewController, navigationController: UINavigationController) {
        self.splitViewController = splitViewController
        self.navigationController = navigationController
        newUserViewController = NewUserViewController()
        newUserDataSource = NewUserDataSource(userFactory: userFactory)
    }

    // MARK: - Coordinator Lifecycle

    func start() {
        userFactory.delegate = self
        popOverNavController.viewControllers = [newUserViewController]
        newUserViewController.coordinator = self
        newUserViewController.dataSource = newUserDataSource
        navigationController.present(popOverNavController, animated: true)
    }

    func didFinish() {
        popOverNavController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(self)
    }

    // MARK: - Navigation

    func showSelectionView(type: SelectionType) {
        guard let groups = userFactory.groupsAvailable()
        else { return }
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

    // MARK: - Actions

    func createUser() {
        userFactory.createUser()
    }

    // MARK: - Helper Methods

    private func getSelections(for type: SelectionType) -> [String]? {
        switch type {
        case .groups: return userFactory.selectedGroupsFor(role: .member)
        case .subAdmin: return userFactory.selectedGroupsFor(role: .admin)
        case .quota: return [userFactory.quotaType().rawValue]
        }
    }
}
