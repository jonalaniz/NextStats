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
    
    var servers = [NextServer]() {
        didSet {
            servers.sort {
                $0.name < $1.name
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Try and pull server data from keychain if available
        if let data = KeychainWrapper.standard.data(forKey:"servers") {
            if let savedServers = try? PropertyListDecoder().decode([NextServer].self, from: data) {
                servers = savedServers
            }
        }
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
        tableView.refreshControl?.endRefreshing()
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Add Server Flow
    // ----------------------------------------------------------------------------
    
    @objc func addServer() {
        if let vc = storyboard?.instantiateViewController(identifier: "AddView") as? AddServerViewController {
            vc.mainViewController = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func returned(with server: NextServer) {
        // Append the new server to the servers array.
        servers.append(server)
        
        // Save servers to keychain encoded as data
        KeychainWrapper.standard.set(try! PropertyListEncoder().encode(servers), forKey:"servers")
        tableView.reloadData()
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - TableView Overrides
    // ----------------------------------------------------------------------------
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), animations: {
            cell.alpha = 1
        })
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ServerCell
        let backgroundAlpha = (0.1 + (Double(indexPath.row) * 0.1))
        
        cell.server = servers[indexPath.row]
        cell.configureCell()
        cell.contentView.backgroundColor = UIColor(red: 44/255, green: 48/255, blue: 78/255, alpha: CGFloat(backgroundAlpha))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedServer = servers[indexPath.row]
        delegate?.serverSelected(selectedServer)
        
        if let statViewController = delegate as? StatsViewController, let statNavigationController = statViewController.navigationController {
            splitViewController?.showDetailViewController(statNavigationController, sender: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove server from array and tableView
            servers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)

            // Save servers to keychain encoded as data
            KeychainWrapper.standard.set(try! PropertyListEncoder().encode(servers), forKey:"servers")
        }
    }

}
