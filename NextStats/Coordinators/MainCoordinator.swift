//
//  MainCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [SubCoordinator]()
    var splitViewController: UISplitViewController
    
    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }
    
    // This is where we initialize the UISplitViewController
    func start() {
        // Initialize our SplitView
        let mainViewController = ServerViewController()
        let mainNavigationController = UINavigationController(rootViewController: mainViewController)
        let detailViewController = StatsViewController()
        let detailNavigationController = UINavigationController(rootViewController: detailViewController)
        
        splitViewController.viewControllers = [mainNavigationController, detailNavigationController]
        mainViewController.delegate = detailViewController
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        
        #if !targetEnvironment(macCatalyst)
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        #endif
    }
}
