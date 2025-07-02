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
        let errorAC = ErrorPresenter.shared.errorAlertController(for: error, with: dismissView)
        DispatchQueue.main.async {
            self.usersViewController.loadingView.remove()
            self.usersViewController.tableView.isHidden = true
            self.usersViewController.present(errorAC, animated: true)
        }
    }

    private func dismissView(action: UIAlertAction) {
        usersViewController.dismissController()
    }
}
