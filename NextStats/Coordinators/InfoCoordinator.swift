//
//  InfoCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Coordinator responsible for displaying app information and handling related navigation.
final class InfoCoordinator: NSObject, Coordinator {
    // MARK: - Coordinator

    weak var parentCoordinator: MainCoordinator?
    var childCoordinators = [Coordinator]()

    // MARK: - Dependencies

    private let dataManager = InfoDataManager.shared

    // MARK: - View Controllers

    private let infoVC = InfoViewController()
    private let navigationController = UINavigationController()
    var splitViewController: UISplitViewController

    // MARK: - Initialization

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }

    // MARK: - Coordinator Lifecycle

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
}
