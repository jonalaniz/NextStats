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
    weak var errorHandler: ErrorHandling?

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
                guard let error = error as? APIManagerError else {
                    handle(error: .somethingWentWrong(error: error))
                    return
                }

                handle(error: error)
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
            handle(error: .conversionFailedToHTTPURLResponse)
            return
        }

        // Notify our delegate of loginURL and begin polling and grab custom image
        delegate?.didRecieve(loginURL: loginURL)
        shouldPoll = true

        guard let cleanURL = pollURL.removingPathComponentSafely() else {
            pollForCredentials(at: pollURL, with: token)
            return
        }

        let logoURL = cleanURL.appendingPathComponentSafely(Endpoint.logo.rawValue)
        checkForCustomImage(at: logoURL)

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
                    handle(error: .somethingWentWrong(error: error))
                    return
                }

                guard case .invalidResponse(let response) = error else {
                    handle(error: error)
                    return
                }

                guard response.statusCode == 404 else {
                    handle(error: error)
                    return
                }

                // If we get a 404, then the user has not authenticated
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.shouldPoll ? (self.pollForCredentials(at: url, with: token)) : (nil)
                }
            }
        }
    }

    private func checkForCustomImage(at url: URL) {
        Task {
            do {
                let image = try await UIImage(data: service.fetchImageData(from: url))
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
            handle(error: .dataEmpty)
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

    private func handle(error: APIManagerError) {
        DispatchQueue.main.async {
            self.errorHandler?.handleError(error)
        }
    }

    private func saveImage(to path: String) {
        do {
            try serverImage?.pngData()?.write(to: URL(string: "file://\(path)")!)
        } catch {
            print("Error, image not saved ")
            print(error.localizedDescription)
        }
    }
}
