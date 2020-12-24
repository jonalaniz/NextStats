//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    var tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
    
    var server: NextServer!
    var tableViewDataContainer = ServerTableViewDataManager()
    
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupView()
    }
        
    internal func setupView() {
        // Add Activity Indicator and Open in Safari Button
        let activityIndicatorBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        let openInSafariButton = UIBarButtonItem(image: UIImage(systemName: "safari.fill"), style: .plain, target: self, action: #selector(openInSafari))
        
        navigationItem.rightBarButtonItems = [openInSafariButton, activityIndicatorBarButtonItem]
        
        // Initialize the tableView
        tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        
        // Connect tableView to ViewController
        tableView.delegate = self
        tableView.dataSource = self
        
        // Constrain tableView
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        if server == nil {
            // Hide view if the server is not initialized
            navigationController?.isNavigationBarHidden = true
            tableView.isHidden = true
        }
    }
    
    internal func getStats() {
        activityIndicator.startAnimating()
        
        // Prepare the user authentication credentials
        let passwordData = "\(server.username):\(server.password)".data(using: .utf8)
        let base64PasswordData = passwordData?.base64EncodedString()
        let authString = "Basic \(base64PasswordData!)"
        let url = URL(string: server.URLString)
        let request = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": authString]

        // Begin URLSession
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.displayErrorAndReturn(error: .noResponse)
            } else {
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200:
                        if let data = data {
                            self.parseJSON(json: data)
                        }
                    case 401:
                        self.displayErrorAndReturn(error: .unauthorized)
                    default:
                        self.displayErrorAndReturn(error: .other)
                    }
                }
            }
        }
        task.resume()
    }
    
    internal func parseJSON(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonStream = try? decoder.decode(Monitor.self, from: json) {
            DispatchQueue.main.async {
                guard let server = jsonStream.ocs?.data?.nextcloud else { return }
                guard let webServer = jsonStream.ocs?.data?.server else { return }
                guard let users = jsonStream.ocs?.data?.activeUsers else { return }
                
                self.tableViewDataContainer.updateDataWith(server: server, webServer: webServer, users: users)
                self.tableView.reloadData()
                self.activityIndicator.deactivate()
                self.activityIndicator.isHidden = true
            }
        } else {
            self.displayErrorAndReturn(error: .jsonError)
        }
    }
    
    internal func displayErrorAndReturn(error: ServerError) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: error.typeAndDescription.title, message: error.typeAndDescription.description, preferredStyle: .alert)
            self.activityIndicator.deactivate()
            self.tableView.isHidden = true
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: self.returnToTable))
            self.present(ac, animated: true)
        }
    }
    
    internal func returnToTable(action: UIAlertAction! = nil) {
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func openInSafari() {
        let urlString = server.friendlyURL.addIPPrefix()
        let url = URL(string: urlString)!
        UIApplication.shared.open(url)
    }
    
}

// MARK: - Table View Functions
extension StatsViewController: UITableViewDelegate, UITableViewDataSource {
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewDataContainer.sections()
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataContainer.rows(in: section)
    }
    
    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewDataContainer.sectionLabel(for: section)
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        let section = indexPath.section
        let row = indexPath.row
        
        cell.textLabel?.text = tableViewDataContainer.rowLabel(forRow: row, inSection: section)
        cell.detailTextLabel?.text = tableViewDataContainer.rowData(forRow: row, inSection: section)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.selectionStyle = .none
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }

}

// MARK: - ServerSelectionDelegate
extension StatsViewController: ServerSelectionDelegate {
    internal func serverSelected(_ newServer: NextServer) {
        // Initialize server variable with selected server
        server = newServer
        
        // Reinitialize the tableViewDataContainer (removes previous server data)
        tableViewDataContainer = ServerTableViewDataManager()
        
        // Unhide UI and set Title
        navigationController?.isNavigationBarHidden = false
        tableView.isHidden = false
        title = server.name
        
        // Get server stats
        getStats()
    }
}
