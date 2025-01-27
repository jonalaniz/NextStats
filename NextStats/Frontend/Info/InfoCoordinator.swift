//
//  InfoCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class InfoCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: MainCoordinator?

    let infoVC = InfoViewController()
    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func start() {
        infoVC.coordinator = self

        navigationController.viewControllers = [infoVC]
        splitViewController.present(navigationController, animated: true)
        infoVC.dataManager.checkForProducts()
    }

    func showWebView(urlString: String) {
        let webVC = WebViewController()
        webVC.passedURLString = urlString

        navigationController.pushViewController(webVC, animated: true)
    }

    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
}
