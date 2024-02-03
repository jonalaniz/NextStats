//
//  AddServerCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class AddServerCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()
    let addServerVC: AddServerViewController
    let authenticator = NXAuthenitcator()

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        addServerVC = AddServerViewController()

        authenticator.delegate = self
        authenticator.errorHandler = self
    }

    func start() {
        let initialVC = addServerVC
        initialVC.coordinator = self

        navigationController.viewControllers = [initialVC]
        splitViewController.present(navigationController, animated: true, completion: nil)
    }

    private func showLoginPage(withURlString urlString: String) {
        let webVC = WebViewController()
        webVC.coordinator = self
        webVC.passedURLString = urlString

        addServerVC.headerView.activityIndicatior.deactivate()
        navigationController.pushViewController(webVC, animated: true)
    }

    func requestAuthorization(with urlString: String, named name: String) {
        // Cancel polling endpoint in case it is running from previous attempt
        // Why someone would do this or get this far I don't know?
        authenticator.cancelAuthorization()

        var urlString = urlString
        urlString.isValidIPAddress() ? (urlString.addIPPrefix()) : (urlString.addHTTPPrefix())

        let url = URL(string: urlString)!
        authenticator.requestAuthenitcationObject(at: url, named: name)

        addServerVC.headerView.activityIndicatior.activate()
    }

    func cancelAuthentication() {
        // Cancel polling endpoint
        authenticator.cancelAuthorization()
        parentCoordinator?.childDidFinish(self)
        dismiss()
    }

    func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

extension AddServerCoordinator: NXAuthenticationDelegate {
    func didCapture(server: NextServer) {
        parentCoordinator?.addServer(server)
        parentCoordinator?.childDidFinish(self)
        dismiss()
    }

    func networkError(error: String) {
        addServerVC.updateStatusLabel(with: error)
    }

    func failedToGetCredentials(withError error: ServerManagerAuthenticationError) {
        addServerVC.updateStatusLabel(with: error.description)
    }

    func didRecieve(loginURL: String) {
        showLoginPage(withURlString: loginURL)
    }
}

extension AddServerCoordinator: ErrorHandler {
    func handle(error type: FetchError) {
        switch type {
        case .invalidURL:
            addServerVC.updateStatusLabel(with: .localized(.serverFormEnterValidAddress))
        case .error(let error):
            addServerVC.updateStatusLabel(with: error)
        case .missingResponse:
            addServerVC.updateStatusLabel(with: .localized(.missingResponse))
        case .unexpectedResponse(let response):
            addServerVC.updateStatusLabel(with: "\(String.localized(.unexpectedResponse)) (\(response.statusCode))")
        case .invalidData:
            addServerVC.updateStatusLabel(with: .localized(.invalidData))
        }
    }
}
