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

    var rows: Int {
        switch self {
        case .name, .requiredFields: return 2
        case .groups, .subAdmin, .quota: return 1
        }
    }

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

enum NameField: Int, CaseIterable {
    case username, displayName

    var placeholder: String {
        switch self {
        case .username: return .localized(.usernameRequired)
        case .displayName: return .localized(.displayName)
        }
    }

    var type: TextFieldType {
        return .normal
    }
}

enum RequiredField: Int, CaseIterable {
    case email, password

    var placeholder: String {
        switch self {
        case .email: .localized(.email)
        case .password: .localized(.password)
        }
    }

    var type: TextFieldType {
        switch self {
        case .email: return .email
        case .password: return .password
        }
    }
}
