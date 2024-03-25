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

    let networking = NetworkController.shared
    private var groupsObject: GroupsObject?

    private var userid: String?
    private var displayName: String?
    private var email: String?
    private var password: String?
    private var memberOf = [String]()
    private var adminOf = [String]()
    private var quota: QuotaType = .defaultQuota

    private override init() {}

    func getGroups(for server: NextServer) {
        var components = URLComponents(string: server.URLString)!
        components.clearQueryAndAppend(endpoint: .groups)
        let authString = server.authenticationString()
        let config = networking.config(authString: authString, ocsApiRequest: true)
        let request = URLRequest(url: components.url!)

        Task {
            do {
                let data = try await self.networking.fetchData(with: request,
                                                          config: config)
                let decoder = XMLDecoder()
                let groups = try? decoder.decode(GroupsObject.self, from: data)
                self.groupsObject = groups
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

    func select(groups: [String], for role: GroupRole) {
        switch role {
        case .member: memberOf.append(contentsOf: groups)
        case .admin: adminOf.append(contentsOf: groups)
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

    func set(userid: String) {
        self.userid = userid
    }

    func set(displayName: String) {
        self.displayName = displayName
    }

    func set(email: String) {
        self.email = email
    }

    func set(password: String) {
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
        guard requirementsMet() else {
            delegate?.requirementsNotMet()
            return
        }

        let newUser = NewUser(userid: userid!,
                              password: password,
                              displayName: displayName,
                              email: email,
                              groups: memberOf,
                              subAdmin: adminOf,
                              quota: quota.stringValue(),
                              language: nil)
        encode(newUser)
    }

    private func encode(_ user: NewUser) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
        } catch {
            print(error)
        }
    }

    func requirementsMet() -> Bool {
        guard userid != nil else { return false }

        if email != nil || password != nil {
            return true
        } else {
            return false
        }
    }

    private func reset() {
        userid = nil
        displayName = nil
        email = nil
        password = nil
        groupsObject = nil
        memberOf = []
        adminOf = []
        quota = .defaultQuota
    }
}

protocol NXUserFactoryDelegate: AnyObject {
    func requirementsNotMet()
    func unableToEncodeData()
}
