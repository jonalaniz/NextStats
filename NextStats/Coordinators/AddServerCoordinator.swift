//
//  AddServerCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

class AddServerCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?
    
    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()
    
    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }
    
    func start() {
        let vc = AddServerViewController()
        vc.coordinator = self
        vc.serverManager = ServerManager.shared
        
        navigationController.viewControllers = [vc]
        splitViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func showLoginPage(withURlString urlString: String) {
        let vc = WebViewController()
        vc.coordinator = self
        vc.serverManager = ServerManager.shared
        vc.passedURLString = urlString
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didFinishAdding() {
        parentCoordinator?.childDidFinish(self)
    }
    
}
