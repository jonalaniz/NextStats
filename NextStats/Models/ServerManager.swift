//
//  ServerManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/3/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation
import UIKit

let loginEndpoint = "/index.php/login/v2"
let logoEndpoint = "/index.php/apps/theming/image/logo"
let statEndpoint = "/ocs/v2.php/apps/serverinfo/api/v1/info?format=json"

@objc public protocol ServerManagerDelegate: class {
    /**
     Called when server is successfully added to the manager
     */
    @objc optional func serverAdded()
    
    @objc optional func failedToGetAuthorizationURL(withError error: String)
    
    @objc optional func authorizationDataRecieved(loginURL: String, pollURL: URL, token: String)
}

open class ServerManager {
    // Manages the creation, deletion, encoding, and decoding of server objects
    
    /// Returns the singleton ServerManager instance.
    public static let shared = ServerManager()
    
    /**
     The delegate object for the 'ServerManager'.
     */
    open weak var delegate: ServerManagerDelegate?
    
    var servers = [NextServer]() {
        didSet {
            // sort, then encode array into keychain
            KeychainWrapper.standard.set(try! PropertyListEncoder().encode(servers), forKey:"servers")
        }
    }
    
    init() {
        // try to pull server data from keychain
        if let data = KeychainWrapper.standard.data(forKey:"servers") {
            if let savedServers = try? PropertyListDecoder().decode([NextServer].self, from: data) {
                self.servers = savedServers
                return
            }
        }
        // if data is not available, create empty array
        self.servers = []
    }
    
    //MARK: - Server Authorization Flow
    
    /**
     Requests token and URL for server authorization
     
     */
    func requestAuthorizationURL(withURL url: URL) {
        // Append endpoint to url
        let urlWithEndpoint = url.appendingPathComponent(loginEndpoint)
        
        var request = URLRequest(url: urlWithEndpoint)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, resposne, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.failedToGetAuthorizationURL?(withError: "Not a valid host, please check url")
                }
            } else {
                if let response = resposne as? HTTPURLResponse {
                    // If server not found, alert user and return
                    if response.statusCode == 404 {
                        DispatchQueue.main.async {
                            self.delegate?.failedToGetAuthorizationURL?(withError: "Nextcloud server not found, please check url")
                        }
                        return
                    }

                }
                if let data = data {
                    self.parseJSONFrom(data: data)
                }
            }
        }
        task.resume()
    }
    
    /**
     Parses JSON from server, captures authentication URL and token
     */
    
    func parseJSONFrom(data: Data) {
        let decoder = JSONDecoder()
        
        if let jsonStream = try? decoder.decode(AuthResponse.self, from: data) {
            DispatchQueue.main.async {
                print(jsonStream)
                if let pollURL = URL(string: (jsonStream.poll?.endpoint)!) {
                    if let token = jsonStream.poll?.token {
                        if let loginURL = jsonStream.login {
                            self.delegate?.authorizationDataRecieved?(loginURL: loginURL, pollURL: pollURL, token: token)
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.delegate?.failedToGetAuthorizationURL?(withError: "Unable to parse server response, contact server administrator.")
            }
        }
    }
    
    
    
    
    func addServer() {
        
        delegate?.serverAdded?()
    }
}




