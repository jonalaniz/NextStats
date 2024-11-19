//
//  NextAuthenticationManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/11/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Facilitates the authentication and capturing of server objects.
class NXAuthenticator: NSObject {
    weak var delegate: NXAuthenticationDelegate?
    weak var errorHandler: ErrorHandler?

    private let service = NextcloudService.shared

    private var serverName: String?
    private var serverImage: UIImage?
    private var shouldPoll = false

    func requestAuthenticationObject(at url: URL, named name: String) {
        serverName = name

        Task {
            do {
                let object = try await service.fetchAuthenticationData(url: url)
                await setupAuthenticationObject(with: object)
            } catch {
                guard let errorType = error as? NetworkError else {
                    handle(error: .error(error.localizedDescription))
                    return
                }

                handle(error: errorType)
            }
        }
    }

    @MainActor private func setupAuthenticationObject(with object: AuthenticationObject) {
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

        guard let logoURL = Endpoint.logo.url(relativeTo: pollURL) else {
            pollForCredentials(at: pollURL, with: token)
            return
        }

        checkForCustomImage(at: logoURL)
        print(logoURL)

        pollForCredentials(at: pollURL, with: token)
    }

    private func pollForCredentials(at url: URL, with token: String) {
        guard shouldPoll else { return }

        Task {
            do {
                let object = try await service.fetchLoginObject(from: url, with: token)

                await createServerFrom(object)
            } catch {
                guard let error = error as? APIManagerError else {
                    handle(error: .error(error.localizedDescription))
                    return
                }

                guard case .invalidResponse(let response) = error else {
                    // TODO: Handle errors
                    return
                }

                guard response == 404 else {
                    return
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.shouldPoll ? (self.pollForCredentials(at: url, with: token)) : (nil)
                }
            }
        }
    }

    private func checkForCustomImage(at url: URL) {
        Task {
            do {
                let image = try await UIImage(data: service.fetchData(from: url))
                self.serverImage = image
            } catch {
                return
            }
        }
    }

    @MainActor private func createServerFrom(_ object: LoginObject) {
        let server: NextServer

        guard
            let url = object.server,
            let username = object.loginName,
            let password = object.appPassword
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

    func cancelAuthorization() {
        shouldPoll = false
    }

    private func decode<T: Decodable>(modelType: T.Type, from data: Data) -> T? {
        let decoder = JSONDecoder()
        guard let object = try? decoder.decode(modelType, from: data) else { return nil }

        return object
    }

    private func handle(error: NetworkError) {
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
