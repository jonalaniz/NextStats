//
//  NextAuthenticationManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/11/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Facilitates the authentication and capturing of server objects.
class NXAuthenticationManager {
    weak var delegate: NXAuthenticationDelegate?
    weak var errorHandler: ErrorHandler?

    // You will die soon...
    private let networkController = NetworkController.shared
    private let dataManager = DataManager.shared

    private var serverName: String?
    private var serverImage: UIImage?
    private var shouldPoll = false

    func neoRequestAuthenticationObject(urlString: String, named name: String) {
        serverName = name

        dataManager.getAuthenticationDataWithSuccess(urlString: urlString) { data, error  in

            // Check for errors and handle them appropriately
            guard error == nil else {
                let foundError = error!
                self.errorHandler?.handle(error: foundError)
                return
            }

            guard
                let data = data,
                let authenticationObject = self.decode(modelType: AuthenticationObject.self, from: data)
            else {
                self.errorHandler?.handle(error: .invalidData)
                return
            }

            // We made it, start authentication
            // TODO: Work on main thread orchestration
            DispatchQueue.main.async {
                self.setupAuthenitcationObject(with: authenticationObject)
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
        logoURL.replacePathWith(endpoint: .logoEndpoint)
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

    /// Sends an HTTP DELETE request to specificed server, clearing app specific password
    /// and deauthorizing NextStats
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

        DataManager.loadDataFromURL(with: request, config: config) { data, error in
            guard error == nil else {
                // TODO: Handle deauthorization errors in app, direct users to
                // deautorize manaully in Nextcloud
                print("Deauthorization error: \(error!)")
                return
            }

            guard data != nil else {
                print("Data is empty ☹️")
                return
            }
        }
    }
}

// MARK: Helper Functions
extension NXAuthenticationManager {
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
