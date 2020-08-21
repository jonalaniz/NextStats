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

@objc public protocol ServerManagerAuthenticationDelegate: class {
    
    /**
     Called when server is successfully added to the manager
     */
    func failedToGetAuthorizationURL(withError error: String)
    
    func authorizationDataRecieved(loginURL: String)
    
    func serverCredentialsCaptured()
}

open class ServerManager {
    // Manages the creation, deletion, encoding, and decoding of server objects
    
    /// Returns the singleton ServerManager instance.
    public static let shared = ServerManager()
    
    /**
     The delegate object for the 'ServerManager'.
     */
    open weak var delegate: ServerManagerAuthenticationDelegate?
    
    var shouldPoll = false
        
    var name: String?
    
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
    func requestAuthorizationURL(withURL url: URL, withName name: String) {
        // Give our server a name
        self.name = name
        
        // Append endpoint to url
        let urlWithEndpoint = url.appendingPathComponent(loginEndpoint)
        
        var request = URLRequest(url: urlWithEndpoint)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, resposne, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.failedToGetAuthorizationURL(withError: "Not a valid host, please check url")
                }
            } else {
                if let response = resposne as? HTTPURLResponse {
                    // If server not found, alert user and return
                    if response.statusCode == 404 {
                        DispatchQueue.main.async {
                            self.delegate?.failedToGetAuthorizationURL(withError: "Nextcloud server not found, please check url")
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
                            self.shouldPoll = true
                            self.delegate?.authorizationDataRecieved(loginURL: loginURL)
                            self.pollForCredentials(at: pollURL, with: token)
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.delegate?.failedToGetAuthorizationURL(withError: "Unable to parse server response, contact server administrator.")
            }
        }
    }
    
    /**
     Begins polling the server for authorization credentials
     */
    
    func pollForCredentials(at url: URL, with token: String) {
        // attach token and setup request
        let tokenPrefix = "token="
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.httpBody = (tokenPrefix + token).data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                // TODO: Error
                return
            } else {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        print("Poll Status Code: \(response.statusCode)")
                        if self.shouldPoll {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.pollForCredentials(at: url, with: token)
                            }
                        }
                        // TODO: Error
                        return
                    }
                    
                }
                if let data = data {
                    print("whats going on here")
                    self.shouldPoll = false
                    self.decodeCredentialsFrom(json: data)
                }
            }
        }
        task.resume()
    }
    
    /**
     Decodes the login credentials from the JSON object
     
     */
    func decodeCredentialsFrom(json: Data) {
        let decoder = JSONDecoder()
        if let credentials = try? decoder.decode(ServerAuthenticationInfo.self, from: json) {
            DispatchQueue.main.async {
                print(credentials)
                self.setupServer(with: credentials)
            }
        }
    }
    
    /**
     Setup values and test for custom logo
     
     */
    func setupServer(with credentials: ServerAuthenticationInfo) {
        if let serverURL = credentials.server, let username = credentials.loginName, let password = credentials.appPassword {
            let URLString = serverURL + statEndpoint
            let friendlyURL = serverURL.makeFriendlyURL()
            let logoURLString = serverURL + logoEndpoint
            let logoURL = URL(string: logoURLString)!
            
            var request = URLRequest(url: logoURL)
            request.httpMethod = "HEAD"
            
            URLSession(configuration: .default).dataTask(with: request) { (_, response, error) in
                print("LOGO:\(logoURL)")
                guard error == nil else {
                    // Logo not found
                    print(error?.localizedDescription)
                    self.captureServer(serverURLString: URLString,friendlyURL: friendlyURL, username: username, password: password, customLogo: false)
                    return
                }
                
                guard(response as? HTTPURLResponse)?.statusCode == 200 else {
                    // Guard against anything but a 200 OK code
                    print("Response: \(response)")
                    self.captureServer(serverURLString: URLString,friendlyURL: friendlyURL, username: username, password: password, customLogo: false)
                    return
                }
                
                // Logo was found
                self.captureServer(serverURLString: URLString,friendlyURL: friendlyURL, username: username, password: password, customLogo: true)
            }.resume()
        } else {
            // Error
        }
    }
    
    /**
     Capture new server and append to array
     */
    func captureServer(serverURLString: String, friendlyURL: String, username: String, password: String, customLogo: Bool) {
        let server = NextServer(name: self.name!, friendlyURL: friendlyURL, URLString: serverURLString, username: username, password: password, hasCustomLogo: customLogo)
        
        servers.append(server)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .serverDidChange, object: nil)
        }
        
    }
    
    func cancelAuthorization() {
        // cancel
    }
}

extension Notification.Name {
    static let serverDidChange = Notification.Name("serversDidChange")
}
