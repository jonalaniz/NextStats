//
//  ServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/14/20.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import UIKit

class ServerViewController: UIViewController {
    let noServersViewController = NoServersViewController()
    var tableView: UITableView!
    var serverManager = NextServerManager.shared
    weak var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        serverManager.delegate = self
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        // Deselect row when returning to view
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }

        #if targetEnvironment(macCatalyst)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        #else
        navigationController?.isToolbarHidden = false
        #endif
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)

        // Toggle table view editing.
        tableView.setEditing(editing, animated: true)
    }

    private func setupView() {
        // Setup Navigation Bar
        title = "NextStats"

        navigationController?.toolbar.configureAppearance()
        navigationController?.navigationBar.prefersLargeTitles = true

        // Set Up Toolbar
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let about = UIBarButtonItem(image: UIImage(systemName: "info.circle.fill"),
                                    style: .plain,
                                    target: self,
                                    action: #selector(infoButtonPressed))
        let infoButton = UIButton()
        infoButton.sfSymbolWithText(symbol: "externaldrive.fill.badge.plus",
                                    text: .localized(.serverAddButton),
                                    color: .themeColor)
        infoButton.setTitleColor(.themeColor, for: .normal)
        let infoButtonItem = infoButton
        infoButtonItem.addTarget(self,
                                 action: #selector(addServerPressed),
                                 for: .touchUpInside)
        infoButtonItem.titleLabel?.font = .boldSystemFont(ofSize: 16)
        infoButtonItem.contentEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)

        let infoButtonView = UIBarButtonItem(customView: infoButtonItem)

        toolbarItems = [infoButtonView, spacer, about]

        // Initialize tableView with proper style for platform and add refreshControl
        #if targetEnvironment(macCatalyst)
        tableView = UITableView(frame: .zero, style: .plain)
        #else
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif

        // Connect tableView to ViewController and register Cell
        tableView.delegate = serverManager
        tableView.dataSource = serverManager
        tableView.register(ServerCell.self, forCellReuseIdentifier: "Cell")

        // Constrain our views
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        // Initial server checking
        serversDidChange(refresh: false)
    }

    @objc func refresh() {
        tableView.reloadData()

        if tableView.refreshControl?.isRefreshing == true {
            tableView.refreshControl?.endRefreshing()
        }
    }

    // Toolbar Buttons: Loads AddServerView and InfoView
    @objc func addServerPressed() {
        coordinator?.showAddServerView()
    }

    @objc func infoButtonPressed() {
        coordinator?.showInfoView()
    }
}

extension ServerViewController: ServerManagerDelegate {
    // THIS FUNCTION SHOULD NOT CHANGE TABLEVIEW IN ANY WAY
    func serversDidChange(refresh: Bool) {
        if serverManager.isEmpty() {
            navigationItem.rightBarButtonItem = nil
            add(noServersViewController)
        } else {
            navigationItem.rightBarButtonItem = editButtonItem
            noServersViewController.remove()
        }

        if refresh { tableView.reloadData() }

        // So iPad doesn't get tableView stuck in editing mode
        setEditing(false, animated: true)
    }

    func pingedServer(at index: Int, isOnline: Bool) {
        print("Needs to implement this next")
    }

    func selected(server: NextServer) {
        coordinator?.showStatsView(for: server)
    }
}
