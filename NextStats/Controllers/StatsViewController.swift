//
//  StatsViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var logoImage: UIImageView!
    
    var serverName: String?
    var urlString: String?
    var user: String?
    var pass: String?
    
    override func viewWillAppear(_ animated: Bool) {
        backgroundImage.layer.cornerRadius = 10
        backgroundImage.layer.opacity = 0.7
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = serverName
        
        getStats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //navigationController?.navigationBar.prefersLargeTitles = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        //navigationController?.navigationBar.isTranslucent = false
    }
    
    func getStats() {
        // Get the server status info
        if urlString != nil {
            if user != nil {
                if pass != nil {
                    let passwordData = "\(user!):\(pass!)".data(using: .utf8)
                    let base64PasswordData = passwordData?.base64EncodedString()
                    let authString = "Basic \(base64PasswordData!)"
                    let url = URL(string: urlString!)
                    let request = URLRequest(url: url!)
                    let config = URLSessionConfiguration.default
                    config.httpAdditionalHeaders = ["Authorization": authString]

                    let session = URLSession(configuration: config)
                    let task = session.dataTask(with: request) {
                        (data, response, error) in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self.displayErrorAndReturn()
                            }
                        } else {
                            if let response = response as? HTTPURLResponse {
                                print("Status Code: \(response.statusCode)")
                            }
                            if let data = data {
                                self.parseJSON(json: data)
                            }
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    func parseJSON(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonStream = try? decoder.decode(Monitor.self, from: json) {
            DispatchQueue.main.async {
                self.updateUI(with: (jsonStream.ocs?.data)!)
                print(jsonStream)
            }
        } else {
            // feck
        }
    }
    
    func updateUI(with stat: DataClass) {
        
    }
    
    func displayErrorAndReturn() {
        let ac = UIAlertController(title: "Error", message: "Cannot reach server, please check your internet connection.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: returnToTable))
        present(ac, animated: true)
    }
    
    func returnToTable(action: UIAlertAction! = nil) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                return cell
    }
    
    
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section: \(section)"
//    }
//
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        view.backgroundColor = .clear
//        view.tintColor = .clear
//    }
    
}
