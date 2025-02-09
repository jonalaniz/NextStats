//
//  UserDataManager.swift
//  UserDataManager
//
//  Created by Jon Alaniz on 7/24/21.
//  Copyright © 2021 Jon Alaniz.
//

// swiftlint:disable identifier_name
import UIKit

enum ResponseType {
    case deletion
    case toggle
}

/// Facilitates the fetching, creation, deletion, and editing of Nextcloud Users
class NXUsersManager: NSObject {
    /// Returns singleton instance of `UserDataManager`
    static let shared = NXUsersManager()

    weak var delegate: NXUserManagerDelegate?
    weak var errorHandler: ErrorHandling?
    private let service = NextcloudService.shared
    private var userIDs = [String]()
    private var users = [User]()
    private(set) var server: NextServer! {
        didSet {
            userIDs.removeAll()
            users.removeAll()
        }
    }

    private override init() {}

    func fetchUsersData() {
        if !users.isEmpty { users.removeAll() }
        if !userIDs.isEmpty { userIDs.removeAll() }

        Task {
            do {
                let object = try await service.fetchUsers(for: server)

                // Here we work with our captured users object
                object.data.users.element.forEach { self.userIDs.append($0) }

                for userID in userIDs {
                    let user = try await service.fetchUser(userID, in: server)
                    users.append(user)
                }

                DispatchQueue.main.async {
                    self.delegate?.stateDidChange(.usersLoaded)
                }
            } catch {
                guard let error = error as? APIManagerError else {
                    handle(error: .somethingWentWrong(error: error))
                    return
                }

                handle(error: error)
            }
        }
    }

    func toggle(user: String) {
        guard let userObject = users.first(where: { $0.data.id == user }) else { return }
        let suffix: String
        userObject.data.enabled ? (suffix = "\(user)/disable") : (suffix = "\(user)/enable")

        Task {
            do {
                let response = try await service.toggleUser(suffix, in: server, type: .disable)

                DispatchQueue.main.async {
                    self.processResponse(user, type: .toggle, response: response)
                }
            } catch {
                guard let error = error as? APIManagerError else {
                    handle(error: .somethingWentWrong(error: error))
                    return
                }

                handle(error: error)
            }
        }

    }

    func delete(user: String) {
        Task {
            do {
                let response = try await service.toggleUser(user, in: server, type: .delete)

                DispatchQueue.main.async {
                    self.processResponse(user, type: .deletion, response: response)
                }
            } catch {
                guard let error = error as? APIManagerError else {
                    handle(error: .somethingWentWrong(error: error))
                    return
                }

                handle(error: error)
            }
        }

    }

    private func processResponse(_ user: String, type: ResponseType, response: GenericResponse) {
        let meta = response.meta
        guard meta.statuscode == 100 else {
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
            return nil
        }

        let userData = users[index].data

        return UserCellModel(userID: userData.id,
                             displayName: userData.displayname ?? "N/A",
                             email: userData.email ?? "N/A",
                             enabled: userData.enabled)
    }

    private func handle(error: APIManagerError) {
        DispatchQueue.main.async {
            self.errorHandler?.handleError(error)
        }
    }
}

extension NXUsersManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userModel = userCellModel(indexPath.row),
              let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell
        else { return UITableViewCell() }

        cell.configureCell(with: userModel)

        return cell
    }
}
