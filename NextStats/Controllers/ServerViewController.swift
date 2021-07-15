//
//  ServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/14/20.
//  Copyright © 2020 Jon Alaniz
//

import UIKit

class ServerViewController: UIViewController {
    let noServersView = NoServersView()
    var tableView: UITableView!
    var serverManager = ServerManager.shared
    weak var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false

        // Deselect row when returning to view
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }

        // Show or hide noServerView as necessary
        toggleNoServersView()
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
        let infoButtonItem = UIButton(type: .system)

        infoButtonItem.setImage(UIImage(systemName: "externaldrive.fill.badge.plus"), for: .normal)
        infoButtonItem.addTarget(self, action: #selector(addServerPressed), for: .touchUpInside)
        infoButtonItem.setTitle(LocalizedKeys.serverAddButton, for: .normal)
        infoButtonItem.titleLabel?.font = .boldSystemFont(ofSize: 16)
        infoButtonItem.contentHorizontalAlignment = .left
        infoButtonItem.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 10)

        let infoButtonView = UIBarButtonItem(customView: infoButtonItem)

        toolbarItems = [infoButtonView, spacer, about]

        // Initialize tableView with proper style for platform
        #if targetEnvironment(macCatalyst)
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        #else
        tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        #endif

        // Connect tableView to ViewController and register Cell
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ServerCell.self, forCellReuseIdentifier: "Cell")

        // Setup Pull To Refresh Controls
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        // Constrain our views
        view.addSubview(tableView)
        view.addSubview(noServersView)

        noServersView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        noServersView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        noServersView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor, constant: 50).isActive = true
    }

    private func toggleNoServersView() {
        // Show noServerView if no ServerManager.servers is empty
        if serverManager.servers.isEmpty {
            navigationItem.rightBarButtonItem = nil
            noServersView.isHidden = false
        } else {
            navigationItem.rightBarButtonItem = editButtonItem
            noServersView.isHidden = true
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
        return serverManager.servers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ServerCell
        else { fatalError("DequeueReusableCell failed while casting")}

        cell.accessoryType = .disclosureIndicator
        cell.server = serverManager.servers[indexPath.row]
        cell.setup()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedServer = serverManager.servers[indexPath.row]
        coordinator?.showStatsView(for: selectedServer)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove server from serverManager and tableView
            serverManager.removeServer(at: indexPath.row)
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
