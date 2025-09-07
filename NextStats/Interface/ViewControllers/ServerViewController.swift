//
//  ServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/14/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

final class ServerViewController: BaseTableViewController {
    // MARK: - Coordinator

    weak var coordinator: MainCoordinator?

    // MARK: - Properties

    // TODO: Remove this serverManager
    private let serverManager = NXServerManager.shared
    private let dataSource = ServerDataSource()

    // MARK: - Views

    let noServersViewController = NoServersViewController()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        titleText = "NextStats"
        tableStyle = isMacCatalyst() ? .plain : .insetGrouped
        delegate = self
        super.viewDidLoad()
        serverManager.pingServers()
        tableView.dataSource = dataSource
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
        super.setupNavigationController()
        navigationController?.navigationBar.applyTheme()
        navigationController?.toolbar.configureAppearance()

        if isMacCatalyst() {
            navigationController?.setNavigationBarHidden(
                true, animated: true
            )
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
        let isiOS26 = SystemVersion.isiOS26
        let infoSymbol = isiOS26 ? SFSymbol.info : SFSymbol.infoFilled
        let addServerButtonView = createToolbarButton(
            symbol: .addServer,
            text: .localized(.serverAddButton),
            action: #selector(addServerPressed))

        let aboutButtonView = createToolbarButton(
            symbol: infoSymbol,
            action: #selector(infoButtonPressed)
        )

        if SystemVersion.isiOS26 {
            navigationItem.rightBarButtonItem = aboutButtonView
            toolbarItems = [.flexibleSpace(), addServerButtonView]
        } else {
            toolbarItems = [
                addServerButtonView, .flexibleSpace(), aboutButtonView
            ]
        }
    }

    override func registerCells() {
        tableView.register(
            ServerCell.self,
            forCellReuseIdentifier: ServerCell.reuseIdentifier
        )
    }

    // MARK: - Actions

    @objc func addServerPressed() {
        coordinator?.showAddServerView()
    }

    @objc func infoButtonPressed() {
        coordinator?.showInfoView()
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

        if SystemVersion.isiOS26 {
            navigationItem.leftBarButtonItem = editButton(hasServers)
        } else {
            navigationItem.rightBarButtonItem = editButton(hasServers)
        }
    }

    // MARK: - Helper Methods

    private func createToolbarButton(
        symbol: SFSymbol, text: String? = nil, action: Selector
    ) -> UIBarButtonItem {
        if #available(iOS 26, *) {
            toolbarButton26(symbol: symbol, text: text, action: action)
        } else {
            toolbarButtonPre26(symbol: symbol, text: text, action: action)
        }
    }

    private func toolbarButtonPre26(
        symbol: SFSymbol, text: String? = nil, action: Selector
    ) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.addTarget(self, action: action, for: .touchUpInside)

        if let systemImage = symbol.image {
            button.setImage(systemImage, for: .normal)
        }

        if let text = text {
            button.setTitle(" \(text)", for: .normal)
            button.titleLabel?.font = .preferredFont(
                forTextStyle: .headline
            )
        }

        return UIBarButtonItem(customView: button)
    }

    @available(iOS 26.0, *)
    private func toolbarButton26(
        symbol: SFSymbol, text: String? = nil, action: Selector
    ) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(
            image: symbol.image,
            style: symbol == .addServer ? .prominent : .plain,
            target: self,
            action: action
        )

        return barButtonItem
    }

    private func editButton(_ valid: Bool) -> UIBarButtonItem? {
        return valid ? editButtonItem : nil
    }
}

// MARK: - UITableViewController

extension ServerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showStatsView(for: serverManager.serverAt(indexPath.row))
    }
}
