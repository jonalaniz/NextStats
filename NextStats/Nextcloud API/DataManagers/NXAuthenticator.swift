//
//  NextAuthenticationManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/11/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

/// Facilitates the authentication and capturing of server objects.
final class NXAuthenticator {

    // MARK: - Singleton

    static let shared = NXAuthenticator()
    private init() {}

    // MARK: - Dependencies

    weak var delegate: NXAuthenticationDelegate?
    weak var errorHandler: ErrorHandling?

    private let service = NextcloudService.shared

    private var serverName: String?
    private var serverImage: UIImage?
    private var shouldPoll = false

    // MARK: - Public API

    func requestAuthenticationObject(at url: URL, named name: String) {
        serverName = name

        Task {
            do {
                let object = try await service.fetchAuthenticationData(
                    url: url
                )
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

    func cancelAuthorization() {
        shouldPoll = false
    }

    // MARK: - Setup Authentication

    @MainActor private func setupAuthenticationObject(
        with object: AuthenticationObject
    ) {
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

        let logoURL = cleanURL.appendingPathComponentSafely(
            Endpoint.logo.rawValue
        )

        checkForCustomImage(at: logoURL)
        pollForCredentials(at: pollURL, with: token)
    }

    // MARK: - Polling

    private func pollForCredentials(at url: URL, with token: String) {
        guard shouldPoll else { return }

        Task {
            do {
                let object = try await service.fetchLoginObject(
                    from: url, with: token
                )
                await createServerFrom(object)
            } catch {
                handlePollingError(error, url: url, token: token)
            }
        }
    }

    private func pollAgain(with url: URL, token: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            pollForCredentials(at: url, with: token)
        }
    }

    private func handlePollingError(_ error: Error, url: URL, token: String) {
        let error = error as? APIManagerError ?? .somethingWentWrong(error: error)

        if case .invalidResponse(let response) = error, response.statusCode == 404 {
            pollAgain(with: url, token: token)
        } else {
            handle(error: error)
        }
    }

    // MARK: - Image Fetching

    private func checkForCustomImage(at url: URL) {
        Task {
            do {
                let image = try await UIImage(
                    data: service.fetchImageData(from: url)
                )
                self.serverImage = image
            } catch {
                return
            }
        }
    }

    private func saveImage(to path: String) {
        do {
            try serverImage?.pngData()?.write(
                to: URL(string: "file://\(path)")!
            )
        } catch {
            print("Error, image not saved ")
            print(error.localizedDescription)
        }
    }

    // MARK: - Server Creation

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

        let urlComponents = URLComponents(
            url: URL(string: url)!, resolvingAgainstBaseURL: false
        )!
        let friendlyURL = urlComponents.host!

        if serverImage != nil {
            server = NextServer(
                name: serverName!,
                friendlyURL: friendlyURL,
                URLString: url,
                username: username,
                password: password,
                hasCustomLogo: true
            )
            saveImage(to: server.imagePath())

            delegate?.didCapture(server: server)
        } else {
            server = NextServer(
                name: serverName!,
                friendlyURL: friendlyURL,
                URLString: url,
                username: username,
                password: password)

            delegate?.didCapture(server: server)
        }
    }

    // MARK: - Error Handling

    private func handle(error: APIManagerError) {
        DispatchQueue.main.async {
            self.errorHandler?.handleError(error)
        }
    }
}
