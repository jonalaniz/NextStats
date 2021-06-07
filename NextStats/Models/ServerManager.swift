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

// Mark: - ServerManagerAuthenticationError
/// String descriptions for various authentication errors.
@objc public enum ServerManagerAuthenticationError: Int {
    
    // Error was given when trying to connect to a host.
    case notValidHost
    
    // Nextcloud server was not found at the specified endpoint.
    case serverNotFound
    
    // ServerManager was unable to parse the JSON object returned from the server
    case failedToSerializeResponse
    
    public var description: String {
        switch self {
        case .notValidHost: return "Not a valid host, please check url."
        case .serverNotFound: return "Nextcloud server not found, please check url."
        case .failedToSerializeResponse: return "Unable to serialize server response."
        }
    }
}

// MARK: - ServerManagerAuthenticationDelegate
/**
 The 'ServerManagerAuthenticationDelegate' protocol defines methods you can implement to respond to events associated with authenticating and adding Nextcloud server instances to the ServerManager.
 */

@objc public protocol ServerManagerAuthenticationDelegate {
    
    /**
     Called when ServerManager is unable to get authorization data from server. Returns error information.
     
     - paramater: error: String
     */
    func failedToGetAuthorizationURL(withError error: ServerManagerAuthenticationError)
    
    /**
     Called when login url and associated authorization data is recieved.
     
    - paramater: loginURL: String
     */
    func authorizationDataRecieved(loginURL: String)
    
    /**
     Called when server is successfully added to the manager
     */
    func serverCredentialsCaptured()
}

// MARK: - ServerManager
/**
 ServerManager facilitates the creation, deletion, encoding, and decoding of Nextcloud server objects.
 */

open class ServerManager {
    // MARK: - Properties
    
    /// Returns the singleton 'ServerManager' instance.
    public static let shared = ServerManager()
    
    /// The delegate object for the 'ServerManager'.
    open weak var delegate: ServerManagerAuthenticationDelegate?
    let networkController = NetworkController.shared
    
    var shouldPoll = false
    var name: String?
    
    var servers = [NextServer]() {
        didSet {
            // Encode new server value into keychain
            KeychainWrapper.standard.set(try! PropertyListEncoder().encode(servers), forKey:"servers")
        }
    }
    
    init() {
        guard
            let data = KeychainWrapper.standard.data(forKey: "servers"),
            let savedServers = try? PropertyListDecoder().decode([NextServer].self, from: data)
        else { return }
        
        self.servers = savedServers
    }

    //MARK: - Server Authorization Flow
    
    /**
     1. Request authorization from server, ServerManager uses Login flow v2 as detailed in the Nextcloud Manual.
     
     - parameter: url: URL of the server we are attempting to gain authorization
     - parameter: name: String used as the name for the server
     */
    func requestAuthorizationURL(withURL url: URL, withName name: String) {
        // Set name value
        self.name = name
        
        // Append Login flow v2 endpoint and create request
        let urlWithEndpoint = url.appendingPathComponent(loginEndpoint)
        var request = URLRequest(url: urlWithEndpoint)
        request.httpMethod = "POST"
        
        networkController.fetchData(with: request) { (result: Result<Data, FetchError>) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let fetchError):
                    switch fetchError {
                    case .unexpectedResponse(let response):
                        if response == 404 {
                            self.delegate?.failedToGetAuthorizationURL(withError: .serverNotFound)
                        } else {
                            self.delegate?.failedToGetAuthorizationURL(withError: .notValidHost)
                        }
                    default:
                        self.delegate?.failedToGetAuthorizationURL(withError: .notValidHost)
                    }
                case .success(let data):
                    self.parseJSONFrom(data: data)
                    self.shouldPoll = true
                }
            }
        }
    }
    
    /**
     2. Parse JSON from server, capture authentication URL and token for polling, and send loginURL to delegate.
     */
    
    private func parseJSONFrom(data: Data) {
        let decoder = JSONDecoder()
        
        guard let jsonStream = try? decoder.decode(AuthResponse.self, from: data) else {
            self.delegate?.failedToGetAuthorizationURL(withError: .failedToSerializeResponse)
            return
        }
        
        guard
            let pollURL = URL(string: (jsonStream.poll?.endpoint)!),
            let token = jsonStream.poll?.token,
            let loginURL = jsonStream.login
        else {
            self.delegate?.failedToGetAuthorizationURL(withError: .failedToSerializeResponse)
            return
        }
        
        self.delegate?.authorizationDataRecieved(loginURL: loginURL)
        self.pollForCredentials(at: pollURL, with: token)
    }
    
    /**
     Begins polling the server for authorization credentials
     */
    private func pollForCredentials(at url: URL, with token: String) {
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
    private func decodeCredentialsFrom(json: Data) {
        let decoder = JSONDecoder()
        if let credentials = try? decoder.decode(ServerAuthenticationInfo.self, from: json) {
            DispatchQueue.main.async {
                print(credentials)
                self.setupServer(with: credentials)
            }
        }
    }
    
    /// Setup values and test for custom logo
    private func setupServer(with credentials: ServerAuthenticationInfo) {
        guard
            let serverURL = credentials.server,
            let username = credentials.loginName,
            let password = credentials.appPassword
        else {
            // TODO: Create an error type for this case
            return
        }
        
        let URLString = serverURL + statEndpoint
        let friendlyURL = serverURL.makeFriendlyURL()
        let logoURLString = serverURL + logoEndpoint
        let logoURL = URL(string: logoURLString)!
        let request = URLRequest(url: logoURL)
            
        networkController.fetchData(with: request) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(_):
                self.captureServer(serverURLString: URLString,friendlyURL: friendlyURL, username: username, password: password, logo: nil)
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    self.captureServer(serverURLString: URLString,friendlyURL: friendlyURL, username: username, password: password, logo: nil)
                    return
                }
                
                self.captureServer(serverURLString: URLString,friendlyURL: friendlyURL, username: username, password: password, logo: image)
            }
        }
    }
    
    /**
     Capture the new server, append it, and sort the server array.
     */
    private func captureServer(serverURLString: String, friendlyURL: String, username: String, password: String, logo: UIImage?) {
        let server: NextServer
        if let customLogoImage = logo {
            // Image was found, initialize the server object and save the image
            server = NextServer(name: self.name!, friendlyURL: friendlyURL, URLString: serverURLString, username: username, password: password, hasCustomLogo: true)
            saveLogo(image: customLogoImage, to: server.imagePath())
        } else {
            // Failed to open the image, initialize the server object without it.
            server = NextServer(name: self.name!, friendlyURL: friendlyURL, URLString: serverURLString, username: username, password: password, hasCustomLogo: false)
        }
        
        servers.append(server)
        servers.sort(by: { $0.name < $1.name })
        
        DispatchQueue.main.async {
            self.delegate?.serverCredentialsCaptured()
        }
        
    }
    
    /**
     Save  custom server logo
     */
    private func saveLogo(image: UIImage, to path: String) {
        do {
            try image.pngData()?.write(to: URL(string: "file://\(path)")!)
        } catch {
            print("Error, image not saved ")
            print(error.localizedDescription)
        }
    }
    
    /**
     Sets shouldPoll to false and thus stopped the authorization process
     */
    func cancelAuthorization() {
        shouldPoll = false
    }
    
    // MARK: - Server Removal Flow
    func removeServer(at index: Int) {
        // Check for and remove image first
        let fileManager = FileManager.default
        let path = servers[index].imagePath()
        
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        // Remove server from the server array
        servers.remove(at: index)
    }
}


