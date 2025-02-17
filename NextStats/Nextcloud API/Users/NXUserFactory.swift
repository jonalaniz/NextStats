//
//  NewUserFactory.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/19/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

enum GroupRole {
    case member, admin
}

class NXUserFactory: NSObject {
    public static let shared = NXUserFactory()

    weak var delegate: NXUserFactoryDelegate?

    let service = NextcloudService.shared
    private var groupsObject: GroupsObject?

    private(set) var userid: String?
    private(set) var displayName: String?
    private(set) var email: String?
    private(set) var password: String?
    private var memberOf = [String]()
    private var adminOf = [String]()
    private var quota: QuotaType = .defaultQuota

    private override init() {}

    func getGroups(for server: NextServer) {
        Task {
            do {
                let object = try await service.fetchGroups(for: server)
                self.groupsObject = object
            } catch {
                print(error)
            }
        }
    }

    func groupsAvailable() -> [String]? {
        guard let container = groupsObject?.data.groups.element
        else { return nil }

        switch container {
        case .string(let string): return [string]
        case .stringArray(let array): return array
        }
    }

    func selectedGroupsFor(role: GroupRole) -> [String] {
        switch role {
        case .member: return memberOf
        case .admin: return adminOf
        }
    }

    func quotaType() -> QuotaType {
        return quota
    }

    func set(userid: String?) {
        self.userid = userid
    }

    func set(displayName: String?) {
        self.displayName = displayName
    }

    func set(email: String?) {
        print("Email: \(email)")
        self.email = email
    }

    func set(password: String?) {
        print("Password: \(password)")
        self.password = password
    }

    func set(groups: [String]) {
        memberOf = groups
    }

    func set(adminOf groups: [String]) {
        adminOf = groups
    }

    func set(quota: String) {
        guard let selectedQuota = QuotaType(rawValue: quota)
        else { return }

        self.quota = selectedQuota
    }

    func createUser() {
        let newUser = NewUser(userid: userid!,
                              password: password,
                              displayName: displayName,
                              email: email,
                              groups: memberOf,
                              subAdmin: adminOf,
                              quota: quota.stringValue())

        do {
            let data = try JSONEncoder().encode(newUser)
            delegate?.stateDidChange(.userCreated(data: data))
        } catch {
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
        reset()
    }

    func checkRequirements() {
        guard let userid = userid, !userid.isEmpty else { return }
        let requirementsMet = !(email?.isEmpty ?? true) || !(password?.isEmpty ?? true)
        if requirementsMet { delegate?.stateDidChange(.ready) }
    }

    private func reset() {
        userid = nil
        displayName = nil
        email = nil
        password = nil
        groupsObject = nil
        memberOf.removeAll()
        adminOf.removeAll()
        quota = .defaultQuota
    }

    private func handle(error: NXUserFactoryErrorType) {
        delegate?.error(error)
    }
}
