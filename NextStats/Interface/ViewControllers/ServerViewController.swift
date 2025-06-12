//
//  ServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/14/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

// swiftlint:disable weak_delegate
class ServerViewController: BaseTableViewController {
    // MARK: - Properties

    let noServersViewController = NoServersViewController()
    let serverManager = NXServerManager.shared

    weak var coordinator: MainCoordinator?
    private var tableDelegate: ServerTableViewDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        titleText = "NextStats"
        tableStyle = isMacCatalyst() ? .plain : .insetGrouped
        tableDelegate = ServerTableViewDelegate(coordinator: coordinator,
                                                serverManager: serverManager)
        delegate = tableDelegate
        super.viewDidLoad()
        serverManager.delegate = coordinator
        serverManager.pingServers()
        add(noServersViewController)
        coordinator?.serversDidChange(refresh: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Deselect row when returning to view
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    // MARK: - Configuration

    override func setupNavigationController() {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.theme]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.largeTitleTextAttributes = attributes
        navigationController?.toolbar.configureAppearance()

        if isMacCatalyst() {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.isToolbarHidden = false
        }
    }

    override func setupTableView() {
        super.setupTableView()
        if !isMacCatalyst() {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }

        tableView.rowHeight = 100
    }

    override func setupToolbar() {
        let addServerButtonView = createToolbarButton(image: "externaldrive.fill.badge.plus",
                                                      text: .localized(.serverAddButton),
                                                      action: #selector(addServerPressed))

        let aboutButtonView = createToolbarButton(image: "info.circle.fill",
                                                  action: #selector(infoButtonPressed))

        toolbarItems = [addServerButtonView, .flexibleSpace(), aboutButtonView]
    }

    override func registerCells() {
        tableView.register(ServerCell.self, forCellReuseIdentifier: ServerCell.reuseIdentifier)
    }

    // MARK: - Actions

    @objc func addServerPressed() {
        coordinator?.showAddServerView()
    }

    @objc func infoButtonPressed() {
        coordinator?.showInfoView()
    }

    @objc func menuTapped() {
        guard coordinator?.statsViewController.serverInitialized != false
        else { return }
        coordinator?.statsViewController.menuTapped()
    }

    @objc func refresh() {
        tableView.reloadData()
        serverManager.pingServers()
        tableView.refreshControl?.endRefreshing()
    }

    // MARK: - UI Updates

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }

    func updateUIBasedOnServerState() {
        let hasServers = serverManager.serverCount() > 0
        tableView.isHidden = !hasServers
        noServersViewController.view.isHidden = hasServers
        navigationItem.rightBarButtonItem = hasServers ? editButtonItem : nil
    }

    // MARK: - Helper Methods

    private func createToolbarButton(image: String, text: String? = nil, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.addTarget(self, action: action, for: .touchUpInside)

        if let systemImage = UIImage(systemName: image) {
            button.setImage(systemImage, for: .normal)
        }

        if let text = text {
            button.setTitle(" \(text)", for: .normal)
            button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        }

        return UIBarButtonItem(customView: button)
    }
}
