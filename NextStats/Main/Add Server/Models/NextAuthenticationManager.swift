//
//  NextAuthenticationManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/11/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Facilitates the authentication and capturing of server objects.
class NextAuthenticationManager {
    weak var delegate: NextAuthenticationDelegate?
    private let networkController = NetworkController.shared

    private var serverName: String?
    private var serverImage: UIImage?
    private var shouldPoll = false

    func requestAuthenticationObject(from url: URL, named name: String) {
        serverName = name

        // Append Login Flow V2 endpoint and create request
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.clearQueryAndAppend(endpoint: .loginEndpoint)
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"

        networkController.fetchData(with: request) { (result: Result<Data, FetchError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let authenitcationObject = self.decode(modelType: AuthenticationObject.self, from: data) {
                        self.setupAuthenitcationObject(with: authenitcationObject)
                    } else {
                        self.delegate?.failedToGetCredentials(withError: .failedToSerializeResponse)
                    }
                case .failure(let fetchError):
                    switch fetchError {
                    case .network(let error):
                        self.delegate?.networkError(error: error.localizedDescription)
                    case .unexpectedResponse(let response):
                        if response == 404 {
                            self.delegate?.failedToGetCredentials(withError: .serverNotFound)
                        } else {
                            fallthrough
                        }
                    default:
                        self.delegate?.failedToGetCredentials(withError: .notValidHost)
                    }
                }
            }
        }
    }

    private func setupAuthenitcationObject(with object: AuthenticationObject) {
        // Check for data from authenticationObject
        guard
            let pollURL = URL(string: (object.poll?.endpoint)!),
            let token = object.poll?.token,
            let loginURL = object.login
        else {
            self.delegate?.failedToGetCredentials(withError: .authorizationDataMissing)
            return
        }

        // Notify our delegate of loginURL and begin polling and grab custom image
        self.delegate?.didRecieve(loginURL: loginURL)
        shouldPoll = true

        var logoURL = URLComponents(url: pollURL, resolvingAgainstBaseURL: false)!
        logoURL.clearQueryAndAppend(endpoint: .logoEndpoint)
        checkForCustomImage(at: logoURL.url!)

        pollForCredentials(at: pollURL, with: token)
    }

    private func pollForCredentials(at url: URL, with token: String) {
        // Setup our request
        let tokenPrefix = "token="
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = (tokenPrefix + token).data(using: .utf8)

        networkController.fetchData(with: request) { (result: Result<Data, FetchError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.shouldPoll = false
                    if let loginObject = self.decode(modelType: LoginObject.self, from: data) {
                        self.createServerFrom(object: loginObject)
                    }
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
                        self.delegate?.failedToGetCredentials(withError: .serverNotFound)
                    }
                }
            }
        }
    }

    private func checkForCustomImage(at url: URL) {
        print("Logo URL: \(url)")
        let request = URLRequest(url: url)

        networkController.fetchData(with: request) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(_):
                break
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.serverImage = image
                }
            }
        }
    }

    private func createServerFrom(object loginObject: LoginObject) {
        let server: NextServer

        guard
            let url = loginObject.server,
            let username = loginObject.loginName,
            let password = loginObject.appPassword
        else {
            delegate?.failedToGetCredentials(withError: .authorizationDataMissing)
            return
        }

        let urlComponents = URLComponents(url: URL(string: url)!, resolvingAgainstBaseURL: false)!
        let friendlyURL = urlComponents.host!

        if serverImage != nil {
            server = NextServer(name: serverName!,
                                friendlyURL: friendlyURL,
                                URLString: url,
                                username: username,
                                password: password,
                                hasCustomLogo: true)
            saveImage(to: server.imagePath())

            delegate?.didCapture(server: server)
        } else {
            server = NextServer(name: serverName!,
                                friendlyURL: friendlyURL,
                                URLString: url,
                                username: username,
                                password: password)

            delegate?.didCapture(server: server)
        }
    }

    /// Sends an HTTP DELETE request to specified server
    /// This clears the app specific password and deauthorizes NextStats
    static func deauthorize(server: NextServer) {
        // Create the URL components and append correct path
        var components = URLComponents(string: server.URLString)!
        components.clearQueryAndAppend(endpoint: .appPassword)

        // Configure headers
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": server.authenticationString(),
                                        "OCS-APIREQUEST": "true"]

        // Configure HTTP Request
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"

        NetworkController.shared.fetchData(with: request, using: config) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(let error): print("Error: \(error)")
            case .success(_): return
            }
        }
    }
}

// MARK: Helper Functions
extension NextAuthenticationManager {
    func cancelAuthorization() {
        shouldPoll = false
    }

    private func decode<T: Decodable>(modelType: T.Type, from data: Data) -> T? {
        let decoder = JSONDecoder()
        guard let object = try? decoder.decode(modelType, from: data) else { return nil }

        return object
    }

    private func saveImage(to path: String) {
        do {
            print("Image Path: \(path)")
            try serverImage?.pngData()?.write(to: URL(string: "file://\(path)")!)
        } catch {
            print("Error, image not saved ")
            print(error.localizedDescription)
        }
    }
}
