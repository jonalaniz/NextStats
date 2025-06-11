//
//  AddServerCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class AddServerCoordinator: NSObject, Coordinator {
    // MARK: - Properties

    weak var parentCoordinator: MainCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    private var navigationController = UINavigationController()

    private let addServerVC: AddServerViewController
    private let authenticator: NXAuthenticator
    private let dataSource: AuthenticationDataSource

    // MARK: - Lifecycle

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        self.authenticator = NXAuthenticator()
        addServerVC = AddServerViewController()
        dataSource = AuthenticationDataSource()
    }

    func start() {
        addServerVC.coordinator = self
        addServerVC.dataSource = dataSource
        dataSource.delegate = addServerVC
        authenticator.delegate = self
        authenticator.errorHandler = self

        navigationController.viewControllers = [addServerVC]
        splitViewController.present(navigationController, animated: true, completion: nil)
    }

    // MARK: - Navigation

    private func navigateToLoginPage(withURlString urlString: String) {
        let webVC = WebViewController()
        webVC.coordinator = self
        webVC.passedURLString = urlString

        addServerVC.headerView.activityIndicatior.deactivate()
        navigationController.pushViewController(webVC, animated: true)
    }

    // MARK: - Helper Methods

    func requestAuthorization(with urlString: String, named name: String) {
        // Cancel polling endpoint in case it is running from previous attempt
        // Why someone would do this or get this far I don't know?
        authenticator.cancelAuthorization()

        var urlString = urlString
        urlString.isValidIPAddress() ? (urlString.addIPPrefix()) : (urlString.addHTTPPrefix())

        let url = URL(string: urlString)!
        authenticator.requestAuthenticationObject(at: url, named: name)

        addServerVC.headerView.activityIndicatior.activate()
    }

    func cancelAuthentication() {
        // Cancel polling endpoint
        authenticator.cancelAuthorization()
    }

    func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
        parentCoordinator?.childDidFinish(self)
    }
}

// MARK: - NXAuthenticationDelegate

extension AddServerCoordinator: NXAuthenticationDelegate {
    func didCapture(server: NextServer) {
        parentCoordinator?.addServer(server)
        dismiss()
    }

    func didRecieve(loginURL: String) {
        navigateToLoginPage(withURlString: loginURL)
    }
}

// MARK: - ErrorHandling

extension AddServerCoordinator: ErrorHandling {
    func handleError(_ error: APIManagerError) {
        addServerVC.updateLabel(with: error.localizedDescription)
    }
}
