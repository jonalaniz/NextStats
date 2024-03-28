//
//  NewUsersCoordinator+NXUserFactoryDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/28/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

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
        }
    }

    func error(_ error: NXUserFactoryErrorType) {
        // Stop spinner
        switch error {
        case .factory(let error):
            handleFactoryError(error)
        case .networking:
            break
        case .server(let code, let status, let message):
            handleServerError(code: code, status: status, message: message)
        }
    }

    private func handleFactoryError(_ error: NXUserFactoryError) {
        switch error {
        case .unableToEncodeData:
            showError(title: "Internal Error",
                      description: "Unable to Encode Data",
                      handler: nil)
        }
    }

    private func handleServerError(code: Int, status: String, message: String) {
        guard let statusCode = NewUserStatusCode(rawValue: code) else {
            showError(title: status, description: message, handler: dismissView)
            return
        }

        switch statusCode {
        case .successful: dismissView()
        case .inviteCannotBeSent:
            showError(title: status,
                      description: description,
                      handler: dismissView)
        default: showError(title: status, description: message, handler: nil)

        }
    }

    private func showError(title: String, description: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title.capitalized,
                                        message: description,
                                        preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue",
                                      style: .default,
                                      handler: handler))
        DispatchQueue.main.async {
            self.newUserViewController.present(alert, animated: true)
        }
    }

    private func dismissView(action: UIAlertAction! = nil) {
        parentCoordinator?.updateUsers()
        popOverNavController.dismiss(animated: true)
    }
}
