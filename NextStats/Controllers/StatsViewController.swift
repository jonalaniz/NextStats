//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var statController: UITableView!
    
    var server: NextServer!
    var tableStatContainer = tableStat()
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
        
        activityIndicator.color = .white
        activityIndicator.startAnimating()
    }
    
    func getStats() {
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
                print(jsonStream)
                self.tableStatContainer.updateStats(with: (jsonStream.ocs?.data?.nextcloud)!, webServer: (jsonStream.ocs?.data?.server)!, users: (jsonStream.ocs?.data?.activeUsers)!)
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
            ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: self.returnToTable))
            self.present(ac, animated: true)
        }
        
    }
    
    func returnToTable(action: UIAlertAction! = nil) {
        navigationController?.popViewController(animated: true)
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
                    statController.backgroundColor = .clear
                    statController.sectionHeaderHeight = 40
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
    
    // ----------------------------------------------------------------------------
    // MARK: - Table View Functions
    // ----------------------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStatContainer.statsArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let section = indexPath.section
        let row = indexPath.row
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.text = tableStatContainer.getStatLabel(forRow: row, inSection: section)
        cell.detailTextLabel?.text = tableStatContainer.statsArray[section][row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableStatContainer.statsArray.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return StatGroup.allCases[section].rawValue
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView = UIView(frame: view.bounds)
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor(red: 22/255, green: 24/255, blue: 39/255, alpha: 1)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = .white
    }
}

extension StatsViewController: ServerSelectionDelegate {
    func serverSelected(_ newServer: NextServer) {
        server = newServer
        title = server.name
        setupView(withData: true)
        //isInitialLoad = false
        getStats()
    }
}
