//
//  ServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/14/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class ServerViewController: UIViewController {
    weak var coordinator: MainCoordinator?

    let noServersViewController = NoServersViewController()
    let serverManager = NXServerManager.shared
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        serverManager.delegate = coordinator
        configureNavigationAppearance()
        setupView()
        setupToolbar()
        serverManager.pingServers()
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

    private func setupView() {
        setupTableView()
        addNoServersViewController()

        // Initial server checking
        coordinator?.serversDidChange(refresh: false)
    }

    private func configureNavigationAppearance() {
        title = "NextStats"
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.themeColor]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.largeTitleTextAttributes = attributes
        navigationController?.toolbar.configureAppearance()
        navigationController?.navigationBar.prefersLargeTitles = true

        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: true)
        #else
        navigationController?.isToolbarHidden = false
        #endif
    }

    private func setupTableView() {
        // Initialize tableView with proper style for platform and add refreshControl
        #if targetEnvironment(macCatalyst)
        tableView = UITableView(frame: .zero, style: .plain)
        #else
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif

        tableView.delegate = coordinator
        tableView.dataSource = coordinator
        tableView.rowHeight = 100
        tableView.register(ServerCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        activateFullScreenConstraints(for: tableView)
    }

    private func addNoServersViewController() {
        noServersViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noServersViewController.view)
        activateFullScreenConstraints(for: noServersViewController.view)

        addChild(noServersViewController)
        noServersViewController.didMove(toParent: self)
    }

    func setupToolbar() {
        let addServerButton = UIButton(configuration: .plain())
        let addString: String = .localized(.serverAddButton)
        let aString = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.themeColor,
            .font: UIFont.boldSystemFont(ofSize: 16)]
        aString.prefixingSFSymbol("externaldrive.fill.badge.plus", color: .themeColor)
        aString.append(NSAttributedString(string: " \(addString)", attributes: attributes))
        addServerButton.setAttributedTitle(aString, for: .normal)

        addServerButton.addTarget(self, action: #selector(addServerPressed), for: .touchUpInside)
        let insets = NSDirectionalEdgeInsets(top: 10.0,
                                             leading: 0,
                                             bottom: 14.0,
                                             trailing: 10.0)
        addServerButton.configuration?.contentInsets = insets

        let addServerButtonView = UIBarButtonItem(customView: addServerButton)

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let aboutButton = UIButton(configuration: .plain())
        aboutButton.addTarget(self,
                              action: #selector(infoButtonPressed),
                              for: .touchUpInside)
        aboutButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        let aboutButtonInsets = NSDirectionalEdgeInsets(top: 10.0,
                                                        leading: 10.0,
                                                        bottom: 14.0,
                                                        trailing: 0)
        aboutButton.configuration?.contentInsets = aboutButtonInsets
        let aboutButtonView = UIBarButtonItem(customView: aboutButton)

        toolbarItems = [addServerButtonView, spacer, aboutButtonView]
    }

    @objc func refresh() {
        tableView.reloadData()
        serverManager.pingServers()

        if tableView.refreshControl?.isRefreshing == true {
            tableView.refreshControl?.endRefreshing()
        }
    }

    @objc func menuTapped() {
        guard coordinator?.statsViewController.serverInitialized != false
        else { return }
        coordinator?.statsViewController.menuTapped()
    }

    @objc func addServerPressed() {
        coordinator?.showAddServerView()
    }

    @objc func infoButtonPressed() {
        coordinator?.showInfoView()
    }

    func updateUIBasedOnServerState() {
        let hasServers = serverManager.serverCount() > 0
        tableView.isHidden = !hasServers
        noServersViewController.view.isHidden = hasServers
        navigationItem.rightBarButtonItem = hasServers ? editButtonItem : nil
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
