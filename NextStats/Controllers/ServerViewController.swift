//
//  ServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/14/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class ServerViewController: UITableViewController {
    
    var servers = [NextServer]()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Servers"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServer))
        navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Try and pull server data from keychain if available
        if let data = KeychainWrapper.standard.data(forKey:"servers") {
            if let savedServers = try? PropertyListDecoder().decode([NextServer].self, from: data) {
                servers = savedServers
            }
        }
        
    }
    
    @objc func addServer() {
        if let vc = storyboard?.instantiateViewController(identifier: "AddView") as? AddServerViewController {
            vc.mainViewController = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ServerCell
        cell.server = servers[indexPath.row]
        cell.configureCell()
        //cell.logoImage.image = logos[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "StatsView") as? StatsViewController {
            vc.server = servers[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
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
    
    func returned(with server: NextServer) {
        // Append the new server to the servers array.
        servers.append(server)
        
        // Save servers to keychain encoded as data
        KeychainWrapper.standard.set(try! PropertyListEncoder().encode(servers), forKey:"servers")
        
        tableView.reloadData()
    }

}
