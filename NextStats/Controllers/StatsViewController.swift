//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    @IBOutlet var statController: UITableView!
    
    var server: NextServer!
    var tableViewDataContainer = ServerTableViewDataManager()
    var isInitialLoad = true

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewWillAppear(_ animated: Bool) {
        if (server != nil) {
            setupView(withData: true)
        } else {
            setupView(withData: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupView(withData data: Bool) {
        // Check if initialized with data
        if isInitialLoad {
            // Check if statController is instantiated
            // Keeps iPhone from crashing
            if statController != nil {
                if data {
                    navigationController?.isNavigationBarHidden = false
                    let barButton = UIBarButtonItem(customView: activityIndicator)
                    self.navigationItem.setRightBarButton(barButton, animated: true)
                    
                    statController.delegate = self
                    statController.dataSource = self
                    statController.isHidden = false
                    isInitialLoad = false
                } else {
                    title = ""
                    statController.isHidden = true
                    navigationController?.isNavigationBarHidden = true
                }
            }
        }
    }
    
    func getStats() {
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
    
    func parseJSON(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonStream = try? decoder.decode(Monitor.self, from: json) {
            DispatchQueue.main.async {
                guard let server = jsonStream.ocs?.data?.nextcloud else { return }
                guard let webServer = jsonStream.ocs?.data?.server else { return }
                guard let users = jsonStream.ocs?.data?.activeUsers else { return }
                
                //self.tableViewDataContainer.updateStats(with: server, webServer: webServer, users: users)
                self.tableViewDataContainer.updateDataWith(server: server, webServer: webServer, users: users)
                self.statController.reloadData()
                self.activityIndicator.deactivate()
                self.activityIndicator.isHidden = true
            }
        } else {
            self.displayErrorAndReturn(error: .jsonError)
        }
    }
    
    func displayErrorAndReturn(error: ServerError) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: error.typeAndDescription.title, message: error.typeAndDescription.description, preferredStyle: .alert)
            self.activityIndicator.deactivate()
            self.statController.isHidden = true
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: self.returnToTable))
            self.present(ac, animated: true)
        }
    }
    
    func returnToTable(action: UIAlertAction! = nil) {
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: - Table View Functions
extension StatsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewDataContainer.sections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataContainer.rows(in: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewDataContainer.sectionLabel(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let section = indexPath.section
        let row = indexPath.row
        
        cell.textLabel?.text = tableViewDataContainer.rowLabel(forRow: row, inSection: section)
        cell.detailTextLabel?.text = tableViewDataContainer.rowData(forRow: row, inSection: section)
        cell.detailTextLabel?.textColor = .secondaryLabel
        return cell
    }

}

// MARK: - ServerSelectionDelegate
extension StatsViewController: ServerSelectionDelegate {
    func serverSelected(_ newServer: NextServer) {
        if statController != nil { statController.isHidden = false }
        server = newServer
        title = server.name
        setupView(withData: true)
        getStats()
    }
}
