//
//  NextAuthenticationManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/11/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Facilitates the authentication and capturing of server objects.
class NXAuthenitcator {
    weak var delegate: NXAuthenticationDelegate?
    weak var errorHandler: ErrorHandler?

//    private let dataManager = DataManager.shared
    private let networking = NetworkController.shared

    private var serverName: String?
    private var serverImage: UIImage?
    private var shouldPoll = false

    // MARK: - New Functions (async/await)
    func requestAuthenitcationObject(at url: URL, named name: String) {
        serverName = name

        Task {
            do {
                let object = try await networking.fetchAuthenticationData(url: url)
                await setupAuthenitcationObject(with: object)
            } catch {
                guard let errorType = error as? FetchError else {
                    handle(error: .error(error.localizedDescription))
                    return
                }

                handle(error: errorType)
            }
        }
    }

    // MARK: - Old Methods (closure based)

    @MainActor private func setupAuthenitcationObject(with object: AuthenticationObject) {
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
        let tokenPrefix = "token="
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = (tokenPrefix + token).data(using: .utf8)

        DataManager.loadDataFromURL(with: request) { data, error in
            guard error == nil else {
                let foundError = error!
                switch foundError {
                case .unexpectedResponse(let response):
                    print("Poll Status Code: \(response.statusCode)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.shouldPoll ? (self.pollForCredentials(at: url, with: token)) : (nil)
                    }
                default:
                    self.delegate?.failedToGetCredentials(withError: .serverNotFound)
                }
                return
            }

            guard
                let loginData = data,
                let loginObject = self.decode(modelType: LoginObject.self, from: loginData)
            else {
                self.handle(error: .invalidData)
                return
            }

            DispatchQueue.main.async {
                self.createServerFrom(object: loginObject)
            }
        }
    }

    private func checkForCustomImage(at url: URL) {
        print("Logo URL: \(url)")
        let request = URLRequest(url: url)

        DataManager.loadDataFromURL(with: request) { data, error in

            guard error == nil else { return }

            guard let capturedData = data else { return }

            guard let image = UIImage(data: capturedData) else { return }

            self.serverImage = image
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
}

// MARK: Helper Functions
extension NXAuthenitcator {
    func cancelAuthorization() {
        shouldPoll = false
    }

    private func decode<T: Decodable>(modelType: T.Type, from data: Data) -> T? {
        let decoder = JSONDecoder()
        guard let object = try? decoder.decode(modelType, from: data) else { return nil }

        return object
    }

    private func handle(error: FetchError) {
        DispatchQueue.main.async {
            self.errorHandler?.handle(error: error)
        }
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