//
//  MainCoordinator.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    
    let mainViewController: ServerViewController
    let detailViewController: StatsViewController
    
    let serverManager = ServerManager.shared
    
    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        
        mainViewController = ServerViewController()
        detailViewController = StatsViewController()
    }
    
    // This is where we initialize the UISplitViewController
    func start() {
        // Initialize our SplitView
        let mainNavigationController = UINavigationController(rootViewController: mainViewController)
        let detailNavigationController = UINavigationController(rootViewController: detailViewController)
        
        splitViewController.viewControllers = [mainNavigationController, detailNavigationController]
        mainViewController.coordinator = self
        mainViewController.delegate = detailViewController
    }
    
    func showInfoView() {
        let vc = InfoViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        splitViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func showAddServerView() {
        let child = AddServerCoordinator(splitViewController: splitViewController, serverManager: serverManager)
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }
    
    func showStatsView() {
        guard let navigationController = detailViewController.navigationController else { return }
        
        splitViewController.showDetailViewController(navigationController, sender: nil)
    }
    
    /// Destroy the addServerCoordinator object and refresh the ServerViewController
    func addServerCoordinatorDidFinish(_ child: AddServerCoordinator?) {
        mainViewController.tableView.reloadData()
        
        childDidFinish(child)
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in
            childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
