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
            showErrorAndReturn(title: .localized(.errorTitle), description: .localized(.authorizationDataMissing))
        case .conversionFailedToHTTPURLResponse:
            showErrorAndReturn(title: .localized(.missingResponse),
                      description: .localized(.missingResponseDescription))
        case .invalidResponse(response: let response):
            showErrorAndReturn(title: .localized(.unexpectedResponse) + "\(response.statusCode)",
                      description: response.description)
        case .invalidURL:
            showErrorAndReturn(title: .localized(.errorTitle),
                      description: .localized(.notValidhost))
        case .serializaitonFailed:
            showErrorAndReturn(title: .localized(.errorTitle),
                      description: .localized(.failedToSerializeResponse))
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
