//
//  AddServerCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Coordinator responsible for managing the flow of adding a new server.
final class AddServerCoordinator: NSObject, Coordinator {
    // MARK: - Coordinator

    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()

    // MARK: - Dependencies

    private let authenticator: NXAuthenticator
    private let dataSource: AuthenticationDataSource

    // MARK: - View Controllers

    private let addServerVC: AddServerViewController
    private let navigationController = UINavigationController()
    var splitViewController: UISplitViewController

    // MARK: - Initialization

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        self.authenticator = NXAuthenticator()
        addServerVC = AddServerViewController()
        dataSource = AuthenticationDataSource()
    }

    // MARK: - Coordinator Lifecycle

    func start() {
        addServerVC.coordinator = self
        addServerVC.dataSource = dataSource
        // TODO: Move datasource ot the AddServerVC
        dataSource.delegate = addServerVC
        authenticator.delegate = self
        authenticator.errorHandler = self

        navigationController.viewControllers = [addServerVC]
        splitViewController.present(
            navigationController,
            animated: true
        )
    }

    func didFinish() {
        navigationController.dismiss(animated: true, completion: nil)
        parentCoordinator?.childDidFinish(self)
    }

    // MARK: - Navigation

    private func navigateToLoginPage(withURlString urlString: String) {
        let webVC = WebViewController()
        webVC.coordinator = self
        webVC.passedURLString = urlString

        addServerVC.headerView.activityIndicatior.deactivate()
        navigationController.pushViewController(webVC, animated: true)
    }

    // MARK: - Actions

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
}

// MARK: - NXAuthenticationDelegate

extension AddServerCoordinator: NXAuthenticationDelegate {
    func didCapture(server: NextServer) {
        parentCoordinator?.addServer(server)
        didFinish()
    }

    func didRecieve(loginURL: String) {
        navigateToLoginPage(withURlString: loginURL)
    }
}

// MARK: - ErrorHandling

extension AddServerCoordinator: ErrorHandling {
    func handleError(_ error: APIManagerError) {
        addServerVC.updateLabel(with: error.description)
    }
}
