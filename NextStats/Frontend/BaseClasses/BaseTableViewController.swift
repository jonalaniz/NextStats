//
//  BaseTableViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/22/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

/// A base view controller that provides a standard table view setup for subclasses.
///
/// `BaseTableViewController` handles the common setup of table views, navigation controllers,
/// and toolbars, allowing subclasses to focus on their specific functionality.
class BaseTableViewController: UIViewController {
    /// The main table view for the view controller.
    var tableView: UITableView!

    /// The data source responsible for providing data to the table view.
    var dataSource: UITableViewDataSource?

    /// The delegate responsible for handling user interactions with the table view.
    weak var delegate: UITableViewDelegate?

    /// The title displayed in the navigation bar.
    var titleText: String?

    /// The style of the table view (e.g., `.plain` or `.insetGrouped`).
    var tableStyle: UITableView.Style = .plain

    /// An optional header view for the table view.
    var tableViewHeaderView: UIView?

    /// A Boolean value indicating whether large titles should be used in the navigation bar.
    var prefersLargeTitles = true

    /// The background image view for the table view.
    var backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background")
        imageView.layer.opacity = 0.5
        return imageView
    }()

    // MARK: - Lifecycle

    /// Called after the controller's view is loaded into memory.
    ///
    /// This method initializes the table view, sets up the navigation controller,
    /// toolbar, and registers table view cells.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationController()
        setupToolbar()
        setupTableView()
        registerCells()
    }

    // MARK: - Setup Methods

    /// Configures the initial view setup, including setting the navigation title.
    func setupView() {
        if let titleText = titleText { title = titleText }
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }

    /// Configures the navigation controller settings.
    ///
    /// This method can be overridden in subclasses to customize navigation bar behavior.
    func setupNavigationController() {}

    /// Configures the toolbar settings.
    ///
    /// This method can be overridden in subclasses to add toolbar items.
    func setupToolbar() {}

    /// Configures the table view, including style, background, delegate, and data source.
    func setupTableView() {
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

    // MARK: - Utility Methods

    /// Checks whether the app is running on macOS Catalyst.
    ///
    /// - Returns: `true` if running on macOS Catalyst, otherwise `false`.
    func isMacCatalyst() -> Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }

    /// Adds a subview that fills the entire view.
    ///
    /// - Parameter subview: The subview to be added and constrained.
    func addFullScreenSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        activateFullScreenConstraints(for: view)
    }

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
