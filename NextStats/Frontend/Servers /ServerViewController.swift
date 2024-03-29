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
        serverManager.delegate = self
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
}

// MARK: - UI Functions
extension ServerViewController {
    @objc func refresh() {
        tableView.reloadData()
        serverManager.pingServers()

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

    private func setupView() {
        // Setup Navigation Bar
        title = "NextStats"

        if let navBar = navigationController?.navigationBar {
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.themeColor]
            navBar.titleTextAttributes = attributes
            navBar.largeTitleTextAttributes = attributes
        }

        navigationController?.toolbar.configureAppearance()
        navigationController?.navigationBar.prefersLargeTitles = true

        // Initialize tableView with proper style for platform and add refreshControl
        #if targetEnvironment(macCatalyst)
        tableView = UITableView(frame: .zero, style: .plain)
        #else
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif

        tableView.delegate = serverManager
        tableView.dataSource = serverManager
        tableView.register(ServerCell.self, forCellReuseIdentifier: "Cell")

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

        let about = UIBarButtonItem(image: UIImage(systemName: "info.circle.fill"),
                                    style: .plain,
                                    target: self,
                                    action: #selector(infoButtonPressed))
        let aboutButton = UIButton(configuration: .plain())
        aboutButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        let aboutButtonInsets = NSDirectionalEdgeInsets(top: 10.0,
                                                        leading: 10.0,
                                                        bottom: 14.0,
                                                        trailing: 0)
        aboutButton.configuration?.contentInsets = aboutButtonInsets
        let aboutButtonView = UIBarButtonItem(customView: aboutButton)

        toolbarItems = [addServerButtonView, spacer, aboutButtonView]
    }
}

// MARK: - NXServerManagerDelegate
extension ServerViewController: NXServerManagerDelegate {
    func deauthorize(server: NextServer) {
        // Create the URL components and append correct path
        var components = URLComponents(string: server.URLString)!
        components.clearQueryAndAppend(endpoint: .appPassword)

        // Configure headers
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": server.authenticationString(),
                                        "OCS-APIREQUEST": "true"]

        // Configure HTTP Request
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"

        Task {
            do {
                _ = try await NetworkController.deauthorize(request: request, config: config)
            } catch {
                DispatchQueue.main.async {
                    self.showError()
                }
            }
        }
    }

    func showError() {
        // TODO: Localize this!
        let message = "Password removed from NextStats, but you may have to delete the app key from within Nextcloud at Personal Settings > Security > Devices & Sessions"

        let errorAC = UIAlertController(title: "Unable to remove NextStats",
                                        message: message,
                                        preferredStyle: .alert)

        errorAC.addAction(UIAlertAction(title: .localized(.statsActionContinue),
                                        style: .default))
        present(errorAC, animated: true)
    }

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
        guard
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ServerCell
        else { return }

        cell.setOnlineStatus(to: isOnline)
    }

    func selected(server: NextServer) {
        coordinator?.showStatsView(for: server)
    }
}
