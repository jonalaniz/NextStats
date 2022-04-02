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
    let addServerViewControlller: AddServerViewController

    let authenticationManager = NextAuthenticationManager()

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        addServerViewControlller = AddServerViewController()

        authenticationManager.delegate = self
    }

    func start() {
        let initialVC = addServerViewControlller
        initialVC.coordinator = self

        navigationController.viewControllers = [initialVC]
        splitViewController.present(navigationController, animated: true, completion: nil)
    }

    private func showLoginPage(withURlString urlString: String) {
        let webVC = WebViewController()
        webVC.coordinator = self
        webVC.passedURLString = urlString

        navigationController.pushViewController(webVC, animated: true)
    }

    func requestAuthorization(withURL url: URL, name: String) {
        // Cancel polling endpoint in case it is running from previous attempt
        // Why someone would do this or get this far I don't know?
        authenticationManager.cancelAuthorization()

        // Request authorization
        authenticationManager.requestAuthenticationObject(from: url, named: name)
    }

    func cancelAuthentication() {
        // Cancel polling endpoint
        authenticationManager.cancelAuthorization()
        parentCoordinator?.childDidFinish(self)
        dismiss()
    }

    func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

extension AddServerCoordinator: NextAuthenticationDelegate {
    func didCapture(server: NextServer) {
        parentCoordinator?.addServer(server)
        parentCoordinator?.childDidFinish(self)
        dismiss()
    }

    func networkError(error: String) {
        addServerViewControlller.updateStatusLabel(with: error)
    }

    func failedToGetCredentials(withError error: ServerManagerAuthenticationError) {
        addServerViewControlller.updateStatusLabel(with: error.description)
    }

    func didRecieve(loginURL: String) {
        showLoginPage(withURlString: loginURL)
    }
}
