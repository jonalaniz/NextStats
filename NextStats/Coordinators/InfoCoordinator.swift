//
//  InfoCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/23/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

class InfoCoordinator: Coordinator {
    weak var parentCoordinator: MainCoordinator?
    
    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()
    
    let infoModel = InfoModel()
    
    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }
    
    func start() {
        let vc = InfoViewController()
        // vc.coordinator = self
        
        navigationController.viewControllers = [vc]
        splitViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func showWebView(urlString: String) {
        let vc = WebViewController()
        vc.passedURLString = urlString
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self)
    }
    
}
