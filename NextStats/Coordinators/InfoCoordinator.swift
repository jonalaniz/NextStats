//
//  InfoCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class InfoCoordinator: NSObject, Coordinator {
    // MARK: - Properties
    private let dataManager = InfoDataManager.shared
    private let infoVC = InfoViewController()

    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    // MARK: - Lifecycle

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func start() {
        infoVC.coordinator = self

        navigationController.viewControllers = [infoVC]
        splitViewController.present(navigationController, animated: true)
        dataManager.checkForProducts()
    }

    // MARK: - Navigation

    func showWebView(urlString: String) {
        let webVC = WebViewController()
        webVC.passedURLString = urlString

        navigationController.pushViewController(webVC, animated: true)
    }

    // MARK: - Helper Methods

    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}
