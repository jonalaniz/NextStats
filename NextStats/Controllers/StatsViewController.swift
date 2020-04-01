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

    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statController.delegate = self
        statController.dataSource = self
        statController.backgroundColor = .clear
        statController.sectionHeaderHeight = 40
        
        title = server.name
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        
        getStats()
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
                DispatchQueue.main.async {
                    self.displayErrorAndReturn(error: .noResponse)
                }
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
            DispatchQueue.main.async {
                self.displayErrorAndReturn(error: .jsonError)
            }
        }
    }
    
    func displayErrorAndReturn(error: ServerError) {
        let ac = UIAlertController(title: error.typeAndDescription.title, message: error.typeAndDescription.description, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: returnToTable))
        present(ac, animated: true)
    }
    
    func returnToTable(action: UIAlertAction! = nil) {
        navigationController?.popViewController(animated: true)
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Table View Functions
    // ----------------------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableStatContainer.tableStatsArray[section].stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let keys = tableStatContainer.keys[indexPath.section]
        let key = keys[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = tableStatContainer.tableStatsArray[indexPath.section].stats[key]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableStatContainer.tableStatsArray.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableStatContainer.tableStatsArray[section].statGroupType
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView = UIView(frame: view.bounds)
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor(red: 22/255, green: 24/255, blue: 39/255, alpha: 1)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = .white
    }
}
