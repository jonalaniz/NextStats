//
//  Coordinators.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/20/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

protocol BaseCoordinator: AnyObject {
    var childCoordinators: [SubCoordinator] { get set }
        
    func start()
}

protocol Coordinator: BaseCoordinator {
    var splitViewController: UISplitViewController { get set }
}

protocol SubCoordinator: BaseCoordinator {
    var navigationController: UINavigationController { get set }
}
