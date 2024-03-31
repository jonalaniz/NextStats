//
//  UserDataManager.swift
//  UserDataManager
//
//  Created by Jon Alaniz on 7/24/21.
//  Copyright © 2021 Jon Alaniz.
//

// swiftlint:disable identifier_name
import Foundation

enum ResponseType {
    case deletion
    case toggle
}

/// Facilitates the fetching, creation, deletion, and editing of Nextcloud Users
class NXUsersManager {
    /// Returns singleton instance of `UserDataManager`
    static let shared = NXUsersManager()

    weak var delegate: NXUserManagerDelegate?
    private let networking = NetworkController.shared
    private var userIDs = [String]()
    private var users = [User]()
    private(set) var server: NextServer! {
        didSet {
            userIDs.removeAll()
            users.removeAll()
        }
    }

    private init() {}

    func fetchUsersData() {
        if !users.isEmpty { users.removeAll() }
        if !userIDs.isEmpty { userIDs.removeAll() }

        let url = URL(string: server.URLString)!
        let authString = server.authenticationString()

        Task {
            do {
                let usersObject = try await networking.fetchUsers(url: url, authentication: authString)

                // Here we work with our captured users object
                usersObject.data.users.element.forEach { self.userIDs.append($0) }

                let configuration = networking.config(authString: authString, ocsApiRequest: true)

                for userID in userIDs {
                    let request = networking.request(url: url, with: .user, appending: userID)
                    let data = try await networking.fetchData(with: request, config: configuration)

                    guard let user = try? XMLDecoder().decode(User.self, from: data) else {
                        throw NetworkError.invalidData
                    }

                    users.append(user)
                }

                DispatchQueue.main.async {
                    self.delegate?.stateDidChange(.usersLoaded)
                }
            } catch {
                guard let networkError = error as? NetworkError else {
                    delegate?.error(.networking(.error(error.localizedDescription)))
                    return
                }
                delegate?.error(.networking(networkError))
            }
        }
    }

    func toggle(user: String) {
        guard let userObject = users.first(where: { $0.data.id == user }) else { return }
        let url = URL(string: server.URLString)!
        let suffix: String
        userObject.data.enabled ? (suffix = "\(user)/disable") : (suffix = "\(user)/enable")
        let authString = server.authenticationString()

        Task {
            do {
                let response = try await networking.toggleUser(suffix, at: url, with: authString)

                DispatchQueue.main.async {
                    self.processResponse(user, type: .toggle, response: response)
                }
            } catch {
                guard let networkError = error as? NetworkError else {
                    delegate?.error(.networking(.error(error.localizedDescription)))
                    return
                }
                delegate?.error(.networking(networkError))
            }
        }

    }

    func delete(user: String) {
        let url = URL(string: server.URLString)!
        let authString = server.authenticationString()

        Task {
            do {
                let response = try await networking.deleteUser(user, at: url, with: authString)
                DispatchQueue.main.async {
                    self.processResponse(user, type: .deletion, response: response)
                }
            } catch {
                guard let networkError = error as? NetworkError else {
                    delegate?.error(.networking(.error(error.localizedDescription)))
                    return
                }
                delegate?.error(.networking(networkError))
            }
        }

    }

    private func processResponse(_ user: String, type: ResponseType, response: Response) {
        let meta = response.meta
        guard meta.statuscode == 100 else {
            self.delegate?.error(.server(status: meta.status,
                                         message: meta.message))
            return
        }

        switch type {
        case .deletion: remove(user: user)
        case .toggle: updateToggleFor(user: user)
        }
    }

    private func updateToggleFor(user: String) {
        if let index = users.firstIndex(where: { $0.data.id
            == user }) {
            users[index].data.enabled.toggle()
        }
        self.delegate?.stateDidChange(.toggledUser)
    }

    private func remove(user: String) {
        userIDs.removeAll(where: { $0 == user })
        users.removeAll(where: { $0.data.id == user })
        self.delegate?.stateDidChange(.deletedUser)
    }

    func setServer(server: NextServer) {
        self.server = server
    }

    // TableView Helper Methods
    func user(id: String) -> User {
        return users.first(where: { $0.data.id == id })!
    }

    func userID(_ index: Int) -> String {
        return userIDs[index]
    }

    func usersCount() -> Int {
        return userIDs.count
    }

    func userCellModel(_ index: Int) -> UserCellModel? {
        guard !users.isEmpty else {
            delegate?.error(.app(.usersEmpty))
            return nil
        }

        let userData = users[index].data

        return UserCellModel(userID: userData.id,
                             displayName: userData.displayname ?? "N/A",
                             email: userData.email ?? "N/A",
                             enabled: userData.enabled)
    }
}
