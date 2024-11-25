//
//  StatsViewController+ErrorHandling.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/20/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension StatsViewController: ErrorHandling {
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

    private func processResponse(code: Int, description: String) {
        guard code != 401 && code != 403 else {
            coordinator?.serverManager.checkWipeStatus(server: dataManager.server!)
            return
        }

        showErrorAndReturn(title: .localized(.unexpectedResponse), description: description)
    }

    private func showErrorAndReturn(title: String, description: String) {
        let errorAC = UIAlertController(title: title,
                                        message: description,
                                        preferredStyle: .alert)
        errorAC.addAction(UIAlertAction(title: .localized(.statsActionContinue),
                                        style: .default,
                                        handler: self.dismissView))

        DispatchQueue.main.async {
            self.loadingView.remove()
            self.tableView.isHidden = true
            self.present(errorAC, animated: true)
        }
    }

    func dismissView(action: UIAlertAction! = nil) {
        tableView.isHidden = true
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }
}
