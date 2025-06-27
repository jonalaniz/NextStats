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
        let errorAC = ErrorPresenter.shared.errorAlertController(for: error, with: dismissView)
        if case .unauthorized = error { checkWipeStatus() }
        DispatchQueue.main.async {
            self.loadingView.remove()
            self.tableView.isHidden = true
            self.present(errorAC, animated: true)
        }
    }

    private func checkWipeStatus() {
        coordinator?.checkWipeStatus()
    }

    func dismissView(action: UIAlertAction! = nil) {
        tableView.isHidden = true
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }
}
