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

    let aboutModel = AboutModel()
    let infoVC = InfoViewController()
    var childCoordinators = [Coordinator]()
    var splitViewController: UISplitViewController
    var navigationController = UINavigationController()

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func start() {
        infoVC.coordinator = self
        infoVC.tableView.dataSource = aboutModel
        infoVC.tableView.delegate = self
        aboutModel.delegate = self
        aboutModel.checkForProducts()

        navigationController.viewControllers = [infoVC]
        splitViewController.present(navigationController, animated: true)
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

extension InfoCoordinator: AboutModelDelegate {
    func iapEnabled() {
        infoVC.tableView.insertSections(IndexSet(integer: AboutSection.support.rawValue), with: .fade)
    }
}

extension InfoCoordinator: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let tableSection = AboutSection(rawValue: indexPath.section)
        else { return }

        let row = indexPath.row

        switch tableSection {
        case .icon:
            aboutModel.toggleIcon()
            infoVC.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        case .licenses: showWebView(urlString: aboutModel.licenseURLFor(row: row))
        case .support: aboutModel.buyProduct(row)
        default: return
        }
    }
}
