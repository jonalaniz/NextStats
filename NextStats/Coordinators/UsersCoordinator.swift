//
//  UsersCoordinator.swift
//  UsersCoordinator
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Coordinator responsible for managing and viewing users.
final class UsersCoordinator: NSObject, Coordinator {
    // MARK: - Coordinator

    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()

    // MARK: - Dependencies

    private let formatter = NXUserFormatter.shared
    let usersManager = NXUsersManager.shared
    private let userFactory = NXUserFactory.shared

    // MARK: - View Controllers

    let usersViewController: UsersViewController
    private let userDetailsController: UserDetailsViewController
    private var navigationController = UINavigationController()
    var splitViewController: UISplitViewController

    // MARK: - Initialization

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        usersViewController = UsersViewController()
        userDetailsController = UserDetailsViewController()
    }

    // MARK: - Coordinator Lifecycle

    func start() {
        usersViewController.coordinator = self
        usersManager.delegate = self
        usersManager.errorHandler = self
        navigationController.viewControllers = [usersViewController]

        splitViewController.present(
            navigationController,
            animated: true
        )
        usersManager.fetchUsersData()
        userFactory.getGroups(for: usersManager.server)
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
        where viewController === userDetailsController || viewController === usersViewController {
            detailNavigationController.viewControllers.remove(at: index)
        }

        parentCoordinator?.childDidFinish(self)
    }

    // MARK: - Navigation

    func showAddUserView() {
        let child = NewUserCoordinator(
            splitViewController: splitViewController,
            navigationController: navigationController
        )
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func showUserView(for userIndex: Int) {
        guard let userModel = usersManager.userCellModel(userIndex) else { return }
        let user = usersManager.user(id: userModel.userID)
        let sections = formatter.buildTableData(for: user)
        userDetailsController.coordinator = self
        userDetailsController.set(user, sections: sections)
        navigationController.pushViewController(userDetailsController, animated: true)
    }

    // MARK: - Actions

    func set(_ server: NextServer) {
        usersManager.setServer(server: server)
    }

    func updateUsers() {
        usersViewController.showLoadingView()
        usersManager.fetchUsersData()
    }

    func delete(user: String) {
        usersManager.delete(user: user)
    }

    func toggle(user: String) {
        usersManager.toggle(user: user)
    }
}

// MARK: UsersManagerDelegate

extension UsersCoordinator: UsersManagerDelegate {
    func userDeleted(_ user: UserCellModel) {
        usersViewController.tableView.reloadData()
        navigationController.popViewController(animated: true)
    }

    func usersLoaded(_ users: [UserCellModel]) {
        usersViewController.updateDataSource(with: users)
    }

    func toggledUser(with id: String) {
        // TODO: Reload UsersViewController
        // TODO: Toggle User in UserDetailView
        userDetailsController.toggleUser()
    }
}
