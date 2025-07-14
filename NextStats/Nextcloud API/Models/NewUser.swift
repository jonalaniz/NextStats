//
//  NewUser.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/14/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

struct NewUser: Codable {
    let userid: String
    let password: String?
    let displayName: String?
    let email: String?
    let groups: [String]?
    let subAdmin: [String]?
    let quota: String?
}

struct UserBuilder {
    var userid: String?
    var password: String?
    var displayName: String?
    var email: String?
    var groups: [String]?
    var subAdmin: [String]?
    var quota: QuotaType = .defaultQuota

    // MARK: - Validation

    var isValid: Bool {
        guard
            let id = userid,
                !id.isEmpty
        else { return false }
        let hasEmail = !(email?.isEmpty ?? true)
        let hasPassword = !(password?.isEmpty ?? true)

        return hasEmail || hasPassword
    }

    // MARK: - User Creation

    func build() throws -> NewUser {
        guard let id = userid else {
            throw NXUserFactoryError.missingRequiredFields(.userId)
        }

        return NewUser(
            userid: id,
            password: password,
            displayName: displayName,
            email: email,
            groups: groups,
            subAdmin: subAdmin,
            quota: quota.serverValue
        )
    }

    mutating func reset() {
        userid = nil
        password = nil
        displayName = nil
        email = nil
        groups = []
        subAdmin = []
        quota = .defaultQuota
    }
}
