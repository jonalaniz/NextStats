//
//  UsersCoordinator.swift
//  UsersCoordinator
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class UsersCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: MainCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    let userFormatter = NXUserFormatter.shared
    let usersManager = NXUsersManager.shared
    let usersViewController: UsersViewController
    let userViewController: UserViewController

    let newUserController = NXUserFactory.shared

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        usersViewController = UsersViewController()
        userViewController = UserViewController()

        usersViewController.usersDataManager.delegate = usersViewController
    }

    func start() {
        usersViewController.coordinator = self
        navigationController.viewControllers = [usersViewController]

        splitViewController.present(navigationController, animated: true)
        newUserController.getGroups(for: usersManager.server)
    }

    func showAddUserView() {
        let child = NewUserCoordinator(splitViewController: splitViewController,
                                       navigationController: navigationController)
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    func showUserView(for user: User) {
        userViewController.dataManager.set(user)
        userViewController.tableView.dataSource = self
        userViewController.setupView()
        navigationController.pushViewController(userViewController, animated: true)
    }

    func updateUsers() {
        usersViewController.usersDataManager.fetchUsersData()
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
        where viewController === userViewController || viewController === usersViewController {
            detailNavigationController.viewControllers.remove(at: index)
        }

        parentCoordinator?.childDidFinish(self)
    }
}

extension UsersCoordinator: NXDataManagerDelegate {
    func stateDidChange(_ dataManagerState: NXDataManagerState) {
        switch dataManagerState {
        case .fetchingData: break
        case .parsingData: break
        case .failed(let nXDataManagerError): break
        case .dataCaptured: break
        }
    }
}
