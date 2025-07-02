//
//  BaseDataTableViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/27/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class BaseDataTableViewController: UIViewController {
    weak var delegate: UITableViewDelegate?

    var tableView: UITableView!
    var titleText: String?
    var tableStyle: UITableView.Style = .plain
    var tableViewHeaderView: UIView?
    var prefersLargeTitles = true

    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background")
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

    func setupTableView() {
        print("TableView setting up")
        tableView = UITableView(frame: .zero, style: tableStyle)
        if let tableViewHeaderView = tableViewHeaderView {
            tableView.tableHeaderView = tableViewHeaderView
        }
        tableView.backgroundColor = .systemBackground
        tableView.backgroundView = backgroundView
        tableView.delegate = delegate
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        activateFullScreenConstraints(for: tableView)
    }

    func registerCells() {}

    // MARK: - Helper Methods

    func isMacCatalyst() -> Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }

    private func activateFullScreenConstraints(for subview: UIView) {
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: view.topAnchor),
            subview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subview.leftAnchor.constraint(equalTo: view.leftAnchor),
            subview.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
