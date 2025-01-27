//
//  BaseTableViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/22/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class BaseTableViewController: UIViewController {
//    weak var coordinator: Coordinator?
    var tableView: UITableView!
    var dataSource: UITableViewDataSource?
    var delegate: UITableViewDelegate?
    var titleText: String?
    var tableStyle: UITableView.Style = .plain
    var tableViewHeaderView: UIView?
    var prefersLargeTitles = true
    // Toolbar Tint Shit
//    var toolbarColor: UIColor = .subHeaderToolbar
//    var toolbarTint: UIColor = .iconsTexts
    var backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background")
        imageView.layer.opacity = 0.5
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationController()
        setupToolbar()
        setupTableView()
        registerCells()
    }

    func setupView() {
        if let titleText = titleText { title = titleText }
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }

    func setupNavigationController() {}

    func setupToolbar() {}

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: tableStyle)
        if let tableViewHeaderView = tableViewHeaderView {
            tableView.tableHeaderView = tableViewHeaderView
        }
        tableView.backgroundColor = .systemBackground
        tableView.backgroundView = backgroundView
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        activateFullScreenConstraints(for: tableView)
    }

    // Override this funciton to
    func registerCells() {}

    /// Activates layout constraints to make the given subview fill the entire view.
    ///
    /// - Parameter subview: The subview to constrain.
    private func activateFullScreenConstraints(for subview: UIView) {
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: view.topAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.leftAnchor.constraint(equalTo: view.leftAnchor),
            subview.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
