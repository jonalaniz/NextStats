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

/// Facilitates the creation, deletion, encoding, and decoding of Nextcloud server objects.
open class ServerManager {
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
            KeychainWrapper.standard.set(try! PropertyListEncoder().encode(servers), forKey: "servers")
        }
    }

    init() {
        guard
            let data = KeychainWrapper.standard.data(forKey: "servers"),
            let savedServers = try? PropertyListDecoder().decode([NextServer].self, from: data)
        else { return }

        self.servers = savedServers
    }

    // MARK: Server Authorization Flow

    /// Request authorization from server, ServerManager uses Login flow v2 as detailed in the Nextcloud Manual.
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

    /// Parse JSON from server, capture authentication URL and token for polling, and send loginURL to delegate.
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

    /// Begins polling the server for authorization credentials
    private func pollForCredentials(at url: URL, with token: String) {
        let tokenPrefix = "token="
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = (tokenPrefix + token).data(using: .utf8)

        networkController.fetchData(with: request) { (result: Result<Data, FetchError>) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let fetchError):
                    switch fetchError {
                    case .unexpectedResponse(let statusCode):
                        print("Poll Status Code: \(statusCode)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if self.shouldPoll {
                                self.pollForCredentials(at: url, with: token)
                            }
                        }
                    default:
                        self.delegate?.failedToGetAuthorizationURL(withError: .serverNotFound)
                    }
                case .success(let data):
                    self.shouldPoll = false
                    self.decodeCredentialsFrom(json: data)
                }
            }
        }
    }

    /// Decodes the login credentials from the JSON object
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
            // Found nil when unwrapping server credentials.
            delegate?.authorizationDataMissing()
            return
        }

        let URLString = serverURL + statEndpoint
        let friendlyURL = serverURL.makeFriendlyURL()
        let logoURLString = serverURL + logoEndpoint
        let logoURL = URL(string: logoURLString)!
        let request = URLRequest(url: logoURL)

        var server = NextServer(name: self.name!,
                                friendlyURL: friendlyURL,
                                URLString: URLString,
                                username: username,
                                password: password)

        networkController.fetchData(with: request) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(_):
                return
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                // Set custom logo and download image
                self.saveLogo(image: image, to: server.imagePath())
                server.setCustomLogo()
                print(server.hasCustomLogo)
                print("is there anyone here?")
            }
            self.captureServer(server)
        }
    }

    /// Append server to array and sort.
    private func captureServer(_ server: NextServer) {
        servers.append(server)
        servers.sort(by: { $0.name < $1.name })

        DispatchQueue.main.async {
            self.delegate?.serverCredentialsCaptured()
        }
    }

    /// Saves custom server logo to disk
    private func saveLogo(image: UIImage, to path: String) {
        do {
            try image.pngData()?.write(to: URL(string: "file://\(path)")!)
        } catch {
            print("Error, image not saved ")
            print(error.localizedDescription)
        }
    }

    // Sets shouldPoll to false and thus stopped the authorization process
    func cancelAuthorization() {
        shouldPoll = false
    }

    // MARK: Server Removal Flow
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

        deleteAppPassword(for: servers[index])

        // Remove server from the server array
        servers.remove(at: index)
    }

    /// Deletes appPassword from server
    func deleteAppPassword(for server: NextServer) {
        // Create the URL with server credentials and append correct path.
        var components = URLComponents(string: server.URLString)!
        components.path = "/ocs/v2.php/core/apppassword"
        components.query = nil

        // Configure http headers
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": server.authenticationString(),
                                        "OCS-APIREQUEST": "true"]

        // Configure HTTP Request
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"

        networkController.fetchData(with: request, using: config) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(let error): print("Error: \(error)")
            case .success(_): return
            }
        }
    }
}
