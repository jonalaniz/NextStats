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
    var serverManager = NewServerManager.shared
    weak var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        toggleNoServersView()
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
        tableView.delegate = self
        tableView.dataSource = self
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
    }

    private func toggleNoServersView() {
        // Show noServerView if no ServerManager.servers is empty
        if serverManager.serverCount() == 0 {
            navigationItem.rightBarButtonItem = nil
            add(noServersViewController)
        } else {
            navigationItem.rightBarButtonItem = editButtonItem
            noServersViewController.remove()
        }

        // So iPad doesn't get tableView stuck in editing mode
        setEditing(false, animated: true)
    }

    @objc func refresh() {
        toggleNoServersView()
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

// MARK: TableView Methods
extension ServerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverManager.serverCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ServerCell
        else { fatalError("DequeueReusableCell failed while casting") }

        let server = serverManager.getServer(at: indexPath.row)
        cell.accessoryType = .disclosureIndicator
        cell.server = server
        cell.setup()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedServer = serverManager.getServer(at: indexPath.row)
        coordinator?.showStatsView(for: selectedServer)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove server from serverManager and tableView
            serverManager.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            // Show or hide noServerView as necessary
            toggleNoServersView()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)

        // Toggle table view editing.
        tableView.setEditing(editing, animated: true)
    }
}
