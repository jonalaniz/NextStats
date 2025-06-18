//
//  ErrorPresentor.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/18/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

/// A structure that repsresents the content to be shown in the error alert.
struct AlertContent {
    let title: String
    let message: String
    let style: UIAlertController.Style
}

class ErrorPresenter {
    // MARK: - Singleton
    static let shared = ErrorPresenter()

    private init() {}

    func errorAlertController(
        for error: APIManagerError,
        with action: @escaping ((UIAlertAction) -> Void)
    ) -> UIAlertController {
        let alertController = UIAlertController(
            title: error.title,
            message: error.description,
            preferredStyle: .alert
        )

        alertController.addAction(alertAction(handler: action))
        return alertController
    }

    private func alertAction(
        handler: @escaping ((UIAlertAction) -> Void)
    ) -> UIAlertAction {
        return UIAlertAction(
            title: .localized(.statsActionContinue),
            style: .default,
            handler: handler
        )
    }
}
