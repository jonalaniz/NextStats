//
//  AddServerCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz
//

import UIKit

class AddServerCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()
    let addServerViewControlller: AddServerViewController

    let serverManager: ServerManager

    init(splitViewController: UISplitViewController, serverManager: ServerManager) {
        self.splitViewController = splitViewController
        self.serverManager = serverManager
        addServerViewControlller = AddServerViewController()

        serverManager.delegate = self
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
        serverManager.cancelAuthorization()

        // Request authorization
        serverManager.requestAuthorizationURL(withURL: url, withName: name)
    }

    func didFinishAdding() {
        // Cancel polling endpoint
        serverManager.cancelAuthorization()

        parentCoordinator?.addServerCoordinatorDidFinish(self)
    }
}

extension AddServerCoordinator: ServerManagerAuthenticationDelegate {
    func networkError(error: String) {
        addServerViewControlller.updateStatusLabel(with: error)
    }

    func failedToGetCredentials(withError error: ServerManagerAuthenticationError) {
        addServerViewControlller.updateStatusLabel(with: error.description)
    }

    func didRecieve(loginURL: String) {
        showLoginPage(withURlString: loginURL)
    }

    func didCaptureCredentials() {
        navigationController.dismiss(animated: true, completion: nil)
        didFinishAdding()
    }
}
