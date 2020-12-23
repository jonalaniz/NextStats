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
    @IBOutlet var serverTableView: UITableView!
    
    weak var delegate: ServerSelectionDelegate?
    
    var serverManager = ServerManager.shared
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        
        if let selectedRow = serverTableView.indexPathForSelectedRow {
            serverTableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverTableView.delegate = self
        serverTableView.dataSource = self
        serverTableView.register(ServerCell.self, forCellReuseIdentifier: "Cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .serverDidChange, object: nil)
    }
    
    private func setupUI() {
        // Setup Background for Catalyst (for blurry sidebar)
        #if targetEnvironment(macCatalyst)
        view.backgroundColor = .clear
        #endif
        
        // Navigation Bar
        navigationItem.rightBarButtonItem = editButtonItem
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "NextStats"
        
        // Setup Pull To Refresh Controls
        serverTableView.refreshControl = UIRefreshControl()
        serverTableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
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
        
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.isTranslucent = false
        navigationController?.toolbar.barTintColor = .systemGroupedBackground
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    @objc func refresh() {
        serverTableView.reloadData()
        if serverTableView.refreshControl?.isRefreshing == true {
            serverTableView.refreshControl?.endRefreshing()
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverManager.servers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = serverTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ServerCell
        
        cell.accessoryType = .disclosureIndicator
        cell.server = serverManager.servers[indexPath.row]
        cell.configureCell()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedServer = serverManager.servers[indexPath.row]
        delegate?.serverSelected(selectedServer)
        
        if let statViewController = delegate as? StatsViewController, let statNavigationController = statViewController.navigationController {
            splitViewController?.showDetailViewController(statNavigationController, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove server from serverManager and tableView
            serverManager.removeServer(at: indexPath.row)
            serverTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // Takes care of toggling the button's title.
            super.setEditing(editing, animated: true)

            // Toggle table view editing.
            serverTableView.setEditing(editing, animated: true)
    }
    
}
