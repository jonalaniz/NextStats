//
//  UserSection.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/11/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum UserSection: Int, CaseIterable {
    case mail = 0, quota, status, capabilities

    var height: CGFloat {
        switch self {
        case .quota: return 66
        default: return 44
        }
    }

    func rows(mailCount: Int?) -> Int {
        switch self {
        case .mail: return mailCount ?? 0
        case .quota: return 1
        case .status: return Status.allCases.count
        case .capabilities: return Capabilities.allCases.count
        }
    }
}

enum Status: Int, CaseIterable {
    case groups, subadmin, language, lastLogin, location, backend

    var title: String {
        switch self {
        case .groups: return "Groups"
        case .subadmin: return "SubAdmin"
        case .language: return .localized(.language)
        case .lastLogin: return .localized(.lastLogin)
        case .location: return .localized(.location)
        case .backend: return .localized(.backend)
        }
    }
}

enum GroupRole {
    case member, admin
}

enum Capabilities: Int, CaseIterable {
    case displayName, password

    var title: String {
        switch self {
        case .displayName: return .localized(.setDisplayName)
        case .password: return .localized(.setPassword)
        }
    }
}
