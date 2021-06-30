//
//  InfoCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/23/21.
//  Copyright © 2021 Jon Alaniz
//

import UIKit

class InfoCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?

    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func start() {
        let infoVC = InfoViewController()
        infoVC.coordinator = self

        navigationController.viewControllers = [infoVC]
        splitViewController.present(navigationController, animated: true, completion: nil)
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
