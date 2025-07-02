//
//  UserDataManager.swift
//  UserDataManager
//
//  Created by Jon Alaniz on 7/24/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

enum ResponseType {
    case deletion
    case toggle
}

/// Facilitates the fetching, creation, deletion, and editing of Nextcloud Users
class NXUsersManager: NSObject {
    /// Returns singleton instance of `UserDataManager`
    static let shared = NXUsersManager()

    weak var delegate: UsersManagerDelegate?
    weak var errorHandler: ErrorHandling?
    private let service = NextcloudService.shared
    private(set) var userIDs = [String]()
    private var users = [User]()
    private(set) var server: NextServer! {
        didSet { resetUserData() }
    }

    private override init() {}

    func fetchUsersData() {
        resetUserData()

        Task {
            do {
                let object = try await service.fetchUsers(for: server)
                object.data.users.element.forEach { self.userIDs.append($0) }

                for userID in userIDs {
                    users.append(try await service.fetchUser(userID, in: server))
                }

                await buildTableData()
            } catch {
                guard let error = error as? APIManagerError else {
                    await handle(error: .somethingWentWrong(error: error))
                    return
                }

                await handle(error: error)
            }
        }
    }

    @MainActor private func buildTableData() {
        // Create rows
        let rows = users.map {
            UserCellModel(
                userID: $0.data.id,
                displayName: $0.data.displayname ?? "N/A",
                email: $0.data.email ?? "N/A",
                enabled: $0.data.enabled
            )
        }
        delegate?.usersLoaded(rows)
    }

    func toggle(user: String) {
        guard let userObject = users.first(
            where: { $0.data.id == user }
        ) else { return }
        let toggleType: ToggleType = userObject.data.enabled ? .disable : .enable

        Task {
            do {
                let response = try await service.toggleUser(
                    toggleType.path(for: user),
                    in: server,
                    type: toggleType
                )
                await processResponse(
                    user,
                    type: .toggle,
                    response: response
                )
            } catch {
                guard let error = error as? APIManagerError else {
                    await handle(error: .somethingWentWrong(error: error))
                    return
                }
                await handle(error: error)
            }
        }

    }

    func delete(user: String) {
        Task {
            do {
                let response = try await service.toggleUser(
                    user, in: server,
                    type: .delete)
                await processResponse(
                    user,
                    type: .deletion,
                    response: response)
            } catch {
                guard let error = error as? APIManagerError else {
                    await handle(error: .somethingWentWrong(error: error))
                    return
                }
                await handle(error: error)
            }
        }

    }

    func setServer(server: NextServer) {
        self.server = server
    }

    @MainActor
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
            let userID = users[index].data.id
            users[index].data.enabled.toggle()
            delegate?.toggledUser(with: userID)
        }
    }

    private func resetUserData() {
        userIDs.removeAll()
        users.removeAll()
    }

    private func remove(user: String) {
        userIDs.removeAll(where: { $0 == user })
        users.removeAll(where: { $0.data.id == user })
        // TODO: Add this back
//        self.delegate?.stateDidChange(.deletedUser)
    }

    @MainActor
    private func handle(error: APIManagerError) {
        errorHandler?.handleError(error)
    }

    func user(id: String) -> User {
        return users.first(where: { $0.data.id == id })!
    }

    func userCellModel(_ index: Int) -> UserCellModel? {
        guard !users.isEmpty else {
            return nil
        }

        let userData = users[index].data

        return UserCellModel(
            userID: userData.id,
            displayName: userData.displayname ?? "N/A",
            email: userData.email ?? "N/A",
            enabled: userData.enabled
        )
    }
}
