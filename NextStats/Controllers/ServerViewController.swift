//
//  ServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/14/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

protocol ServerSelectionDelegate: class {
    func serverSelected(_ newServer: NextServer)
}

class ServerViewController: UIViewController {
    var tableView: UITableView!
    
    weak var delegate: ServerSelectionDelegate?
    
    var serverManager = ServerManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .serverDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Deselect row when returning to view
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    internal func setupView() {
        // Setup Background for Catalyst (for blurry sidebar)
        #if targetEnvironment(macCatalyst)
        view.backgroundColor = .clear
        #endif
        
        // Setup Navigation Bar
        title = "NextStats"
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.isTranslucent = false
        navigationController?.toolbar.barTintColor = .systemGroupedBackground
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Set Up Toolbar
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let about = UIBarButtonItem(image: UIImage(systemName: "info.circle.fill"), style: .plain, target: self, action: #selector(loadInfoView))
        let addButtonIcon = UIButton(type: .system)
        
        addButtonIcon.setImage(UIImage(systemName: "externaldrive.fill.badge.plus"), for: .normal)
        addButtonIcon.addTarget(self, action: #selector(loadAddServerView), for: .touchUpInside)
        addButtonIcon.setTitle(NSLocalizedString("Add Server", comment: ""), for: .normal)
        addButtonIcon.titleLabel?.font = .boldSystemFont(ofSize: 16)
        addButtonIcon.contentHorizontalAlignment = .left
        addButtonIcon.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 10)
            
        let addButtonView = UIBarButtonItem(customView: addButtonIcon)

        toolbarItems = [addButtonView, spacer, about]
        
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
        
        // Constrain tableView
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    @objc func refresh() {
        tableView.reloadData()
        if tableView.refreshControl?.isRefreshing == true {
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Toolbar Buttons: Loads AddServerView and InfoView
    
    @objc func loadAddServerView() {
        if let vc = storyboard?.instantiateViewController(identifier: "AddView") as? AddServerViewController {
            vc.serverManager = self.serverManager
            let navigationController = UINavigationController(rootViewController: vc)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @objc func loadInfoView() {
        if let vc = storyboard?.instantiateViewController(identifier: "InfoView") as? InfoViewController {
            let navigationController = UINavigationController(rootViewController: vc)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - TableView Methods

extension ServerViewController: UITableViewDelegate, UITableViewDataSource {

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverManager.servers.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ServerCell
        
        cell.accessoryType = .disclosureIndicator
        cell.server = serverManager.servers[indexPath.row]
        cell.configureCell()

        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedServer = serverManager.servers[indexPath.row]
        delegate?.serverSelected(selectedServer)
        
        if let statViewController = delegate as? StatsViewController, let statNavigationController = statViewController.navigationController {
            splitViewController?.showDetailViewController(statNavigationController, sender: nil)
        }
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove server from serverManager and tableView
            serverManager.removeServer(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)

        // Toggle table view editing.
        tableView.setEditing(editing, animated: true)
    }
    
}
