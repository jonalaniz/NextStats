//
//  NewUserSection.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/11/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum NewUserSection: Int, CaseIterable {
    case name, requiredFields, groups, subAdmin, quota

    var header: String {
        switch self {
        case .name: return ""
        case .requiredFields: return .localized(.requiredFields)
        case .groups: return .localized(.groups)
        case .subAdmin: return .localized(.setSubAdmin)
        case .quota: return .localized(.quota)
        }
    }
}

enum NewUserItem {
    case username
    case displayName
    case email
    case password
    case groups
    case subadmin
    case quota

    var placeholder: String {
        switch self {
        case .username: return .localized(.usernameRequired)
        case .displayName: return .localized(.displayName)
        case .email: return .localized(.email)
        case .password: return .localized(.password)
        default: return ""
        }
    }

    var tag: Int? {
        switch self {
        case .username: return 10
        case .displayName: return 20
        case .email: return 30
        case .password: return 40
        default: return nil
        }
    }

    var type: TextFieldType {
        switch self {
        case .email: return .email
        case .password: return .password
        default: return .normal
        }
    }

    init?(from tag: Int) {
        switch tag {
        case 10: self = .username
        case 20: self = .displayName
        case 30: self = .email
        case 40: self = .password
        default: return nil
        }
    }

    static func items(for section: NewUserSection) -> [NewUserItem] {
        switch section {
        case .name: return [.username, .displayName]
        case .requiredFields: return [.email, .password]
        case .groups: return [.groups]
        case .subAdmin: return [.subadmin]
        case .quota: return [.quota]
        }
    }
}
