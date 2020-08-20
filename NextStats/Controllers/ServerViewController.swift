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

class ServerViewController: UITableViewController {
    weak var delegate: ServerSelectionDelegate?
    
    var initialLoad = true
    
    var serverManager = ServerManager.shared
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
    }
    
    private func setupUI() {
        // Setup Bar Button Items
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServer))
        navigationItem.leftBarButtonItem = self.editButtonItem
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Setup Pull To Refresh Controls
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl?.tintColor = UIColor.white
    }
    
    @objc func refresh() {
        tableView.reloadData()
        if tableView.refreshControl?.isRefreshing == true {
            tableView.refreshControl?.endRefreshing()
        }
        
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Add Server Flow
    // ----------------------------------------------------------------------------
    
    @objc func addServer() {
        if let vc = storyboard?.instantiateViewController(identifier: "AddView") as? AddServerViewController {
            vc.serverManager = self.serverManager
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
}

// ----------------------------------------------------------------------------
// MARK: - ServerManager Delegate
// ----------------------------------------------------------------------------
extension ServerViewController: ServerManagerDelegate {
    func serverAdded() {
        tableView.reloadData()
    }
}

// ----------------------------------------------------------------------------
// MARK: - ServerManager Delegate
// ----------------------------------------------------------------------------
extension ServerViewController: RefreshServerTableViewDelegate {
    func refreshTableView() {
        tableView.reloadData()
    }
}

// ----------------------------------------------------------------------------
// MARK: - TableView Methods
// ----------------------------------------------------------------------------

extension ServerViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.1 * Double(indexPath.row), animations: {
            cell.alpha = 1
        })
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverManager.servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ServerCell
        let backgroundAlpha = (0.1 + (Double(indexPath.row) * 0.1))
        
        cell.server = serverManager.servers[indexPath.row]
        cell.configureCell()
        cell.contentView.backgroundColor = UIColor(red: 44/255, green: 48/255, blue: 78/255, alpha: CGFloat(backgroundAlpha))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedServer = serverManager.servers[indexPath.row]
        delegate?.serverSelected(selectedServer)
        
        if let statViewController = delegate as? StatsViewController, let statNavigationController = statViewController.navigationController {
            splitViewController?.showDetailViewController(statNavigationController, sender: nil)
        }
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove server from array and tableView
            serverManager.servers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
