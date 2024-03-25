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
    private var quota = String()

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

    func set(groups: [String]) {
        memberOf = groups
    }

    func set(adminOf groups: [String]) {
        adminOf = groups
    }

    func set(quota: String) {
        // Guard
    }

}

protocol NXUserFactoryDelegate: AnyObject {

}
