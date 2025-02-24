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
    weak var coordinator: MainCoordinator?

    private var tableDelegate: ServerTableViewDelegate?

    let noServersViewController = NoServersViewController()
    let serverManager = NXServerManager.shared

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

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
    }

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

    // TODO: Make private
    // This is currently called by the coordinator, will need to be called from the datamanger eventually
    func updateUIBasedOnServerState() {
        let hasServers = serverManager.serverCount() > 0
        tableView.isHidden = !hasServers
        noServersViewController.view.isHidden = hasServers
        navigationItem.rightBarButtonItem = hasServers ? editButtonItem : nil
    }

    private func createToolbarButton(image: String, text: String? = nil, action: Selector) -> UIBarButtonItem {
        guard let image = UIImage(systemName: image)
        else { return UIBarButtonItem() }

        let button = UIButton(configuration: .plain())
        button.addTarget(self, action: action, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit

        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10.0,
                                                              leading: 10.0,
                                                              bottom: 14.0,
                                                              trailing: 10.0)

        if let text = text {
            let attributedString = attributedString(text, image: image)
            button.setAttributedTitle(attributedString, for: .normal)
        } else {
            button.setImage(image, for: .normal)
        }

        button.configuration = configuration
        return UIBarButtonItem(customView: button)
    }

    private func attributedString(_ string: String, image: UIImage) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.theme,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]

        let attributedString = NSMutableAttributedString()
        attributedString.prefixSFSymbol(image, color: .theme)
        attributedString.append(NSAttributedString(string: " \(string)", attributes: attributes))

        return attributedString
    }
}
