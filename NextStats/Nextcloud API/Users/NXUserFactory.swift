//
//  NewUserFactory.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/19/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

final class NXUserFactory: NSObject {
    public static let shared = NXUserFactory()

    weak var delegate: NXUserFactoryDelegate?

    private let service = NextcloudService.shared
    private var builder = UserBuilder()
    private var groupsObject: GroupsObject?

    var displayName: String? { return builder.displayName }
    var email: String? { return builder.email }
    var password: String? { return builder.password }
    var userid: String? { return builder.userid }

    private override init() {}

    func getGroups(for server: NextServer) {
        Task {
            do {
                let object = try await service.fetchGroups(for: server)
                self.groupsObject = object
            } catch {
                delegate?.error(.network(.somethingWentWrong(error: error)))
            }
        }
    }

    func availableGroupNames() -> [String]? {
        guard let container = groupsObject?.data.groups.element
        else { return nil }

        switch container {
        case .string(let string): return [string]
        case .stringArray(let array): return array
        }
    }

    func selectedGroupsStringFor(_ role: GroupRole) -> String? {
        return selectedGroupsFor(role)?.joined(separator: ", ")
    }

    func selectedGroupsFor(_ role: GroupRole) -> [String]? {
        switch role {
        case .member: return builder.groups
        case .admin: return builder.subAdmin
        }
    }

    func quotaType() -> QuotaType {
        return builder.quota
    }

    func set(userid: String?) {
        builder.userid = userid
    }

    func set(displayName: String?) {
        builder.displayName = displayName
    }

    func set(email: String?) {
        builder.email = email
    }

    func set(password: String?) {
        builder.password = password
    }

    func set(groups: [String]) {
        builder.groups = groups
    }

    func set(adminOf groups: [String]) {
        builder.subAdmin = groups
    }

    func set(quota: String) {
        guard let selectedQuota = QuotaType(displayName: quota)
        else { return }
        builder.quota = selectedQuota
    }

    func createUser() {
        do {
            let newUser = try builder.build()
            let data = try JSONEncoder().encode(newUser)
            delegate?.stateDidChange(.userCreated(data: data))
        } catch {
            // TODO: Consolidate errors
            handle(error: .application(.unableToEncodeData))
        }
    }

    func postUser(data: Data, to server: NextServer) {
        Task {
            do {
                let response = try await service.postUser(data, in: server)
                await checkResponse(response)
            } catch {
                guard let networkError = error as? APIManagerError else {
                    delegate?.error(.network(.somethingWentWrong(error: error)))
                    return
                }
                delegate?.error(.network(networkError))
            }
        }
    }

    @MainActor private func checkResponse(_ response: GenericResponse) {
        let meta = response.meta
        guard meta.statuscode == 100
        else {
            delegate?.error(.server(code: meta.statuscode,
                                    status: meta.status,
                                    message: meta.message))
            return
        }
        delegate?.stateDidChange(.sucess)
        builder.reset()
    }

    func checkRequirements() {
        if builder.isValid { delegate?.stateDidChange(.readyToBuild)
        }
    }

    private func handle(error: NXUserFactoryErrorType) {
        delegate?.error(error)
    }
}
