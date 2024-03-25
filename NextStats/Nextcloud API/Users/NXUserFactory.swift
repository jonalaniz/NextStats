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
    private var memberOf = [String]()
    private var adminOf = [String]()
    private var quota = QuotaType.defaultQuota

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

    func createUser(userid: String,
                    displayName: String?,
                    email: String?,
                    password: String?,
                    groups: [String]?,
                    subAdmin: [String]?) {

    }

    func createNewUser() {
        let newUser = NewUser(userid: "Piss",
                              password: nil,
                              displayName: nil,
                              email: nil,
                              groups: nil,
                              subAdmin: nil,
                              quota: nil,
                              language: nil)

        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(newUser)
            let string = String(data: data, encoding: .utf8)
            print(string)
        } catch {
            print(error.localizedDescription)
        }
    }

}

protocol NXUserFactoryDelegate: AnyObject {

}
