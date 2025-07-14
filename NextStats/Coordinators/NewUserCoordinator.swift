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
        popOverNavController.viewControllers = [
            newUserViewController
        ]
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
        guard let groups = userFactory.availableGroupNames()
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
                data: QuotaType.allCases.map(\.displayName),
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

    func selectionMade(in section: NewUserSection) {
        guard userFactory.availableGroupNames() != nil else { return }

        // Only groups/subadmin/quota have segues, ignore other sections
        switch section {
        case .groups: showSelectionView(type: .groups)
        case .subAdmin: showSelectionView(type: .subAdmin)
        case .quota: showSelectionView(type: .quota)
        default: break
        }
    }

    // MARK: - Helper Methods

    private func getSelections(for type: SelectionType) -> [String]? {
        switch type {
        case .groups: return userFactory.selectedGroupsFor(role: .member)
        case .subAdmin: return userFactory.selectedGroupsFor(role: .admin)
        case .quota: return [userFactory.quotaType().displayName]
        }
    }
}

// MARK: - NXUserFactoryDelegate

extension NewUserCoordinator: NXUserFactoryDelegate {
    func stateDidChange(_ state: NXUserFactoryState) {
        switch state {
        case .userCreated(let data):
            guard let server = parentCoordinator?.usersManager.server
            else { return }

            userFactory.postUser(data: data, to: server)
            // Show a spinner or something
        case .sucess:
            // Stop Spinner
            parentCoordinator?.updateUsers()
            popOverNavController.dismiss(animated: true)
        case .readyToBuild: newUserViewController.enableNextButton()
        }
    }

    func error(_ error: NXUserFactoryErrorType) {
        // Stop spinner
        switch error {
        case .application(let error):
            handleFactoryError(error)
        case .network:
            break
        case .server(let code, let status, let message):
            handleServerError(code: code, status: status, message: message)
        }
    }

    private func handleFactoryError(_ error: NXUserFactoryError) {
        switch error {
        case .unableToEncodeData:
            showError(title: .localized(.internalError),
                      description: .localized(.unableToEncodeData),
                      handler: nil)
        case .missingRequiredFields(let field):
            print("Missing Required Field \(field)")
            // TODO: Add missing required fields
        }
    }

    private func handleServerError(code: Int, status: String, message: String) {
        guard let statusCode = NewUserStatusCode(rawValue: code)
        else {
            showError(
                title: status,
                description: message,
                handler: dismissView
            )
            return
        }

        switch statusCode {
        case .successful: dismissView()
        case .inviteCannotBeSent:
            showError(
                title: status,
                description: description,
                handler: dismissView
            )
        default: showError(
            title: status,
            description: message,
            handler: nil
        )
        }
    }

    private func showError(title: String, description: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(
            title: title.capitalized,
            message: description,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: .localized(.statsActionContinue),
            style: .default,
            handler: handler)
        )
        DispatchQueue.main.async {
            self.newUserViewController.present(alert, animated: true)
        }
    }

    private func dismissView(action: UIAlertAction! = nil) {
        parentCoordinator?.updateUsers()
        popOverNavController.dismiss(animated: true)
    }
}
