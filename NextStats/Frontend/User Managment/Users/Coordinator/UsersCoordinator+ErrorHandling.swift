//
//  UsersCoordinator+ErrorHandling.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/20/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension UsersCoordinator: ErrorHandling {
    func handleError(_ error: APIManagerError) {
        switch error {
        case .configurationMissing:
            showErrorAndReturn(title: .localized(.errorTitle), description: error.localizedDescription)
        case .conversionFailedToHTTPURLResponse:
            showErrorAndReturn(title: .localized(.missingResponse),
                               description: error.localizedDescription)
        case .invalidResponse(response: _):
            showErrorAndReturn(title: "Unexpected Response",
                               description: error.localizedDescription)
        case .invalidURL:
            showErrorAndReturn(title: .localized(.errorTitle),
                               description: error.localizedDescription)
        case .maintenance:
            showErrorAndReturn(title: .localized(.maintenanceMode),
                               description: error.localizedDescription)
        case .serializaitonFailed:
            showErrorAndReturn(title: .localized(.errorTitle),
                               description: error.localizedDescription)
        case .somethingWentWrong(error: let error):
            showErrorAndReturn(title: .localized(.errorTitle),
                      description: error.localizedDescription)
        }
    }

    private func showErrorAndReturn(title: String, description: String) {
        let errorAC = UIAlertController(title: title,
                                        message: description,
                                        preferredStyle: .alert)
        errorAC.addAction(UIAlertAction(title: .localized(.statsActionContinue),
                                        style: .default,
                                        handler: dismissView))
    }

    private func dismissView(action: UIAlertAction) {
        usersViewController.dismissController()
    }
}
