//
//  UserSection.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/11/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum UserSection: Int, CaseIterable {
    case mail
    case quota
    case status
    case capabilities

    var rowHeight: CGFloat? {
        switch self {
        case .quota: return 66
        default: return nil
        }
    }

    func header(emails: [String]?, quota: QuotaContainer?) -> String {
        switch self {
        case .mail: return headerFor(emails)
        case .quota: return headerFor(quota)
        case .status: return .localized(.status)
        case .capabilities: return .localized(.capabilities)
        }
    }

    private func headerFor(_ addresses: [String]?) -> String {
        guard addresses != nil
        else { return .localized(.usersNoEmail) }
        return .localized(.usersEmail)
    }

    private func headerFor(_ quota: QuotaContainer?) -> String {
        var string = ""
        guard let quota = quota else { return string }

        switch quota {
        case .int(let int):
            (int > 0) ? (string = .localized(.quota)) : (string = .localized(.quotaUnlimited))
        case .string(let quotaString):
            string = quotaString
        }

        return string
    }

    func rows(mailCount: Int?) -> Int {
        switch self {
        case .mail: return mailCount ?? 0
        case .quota: return 1
        case .status: return StatusRow.allCases.count
        case .capabilities: return Capabilities.allCases.count
        }
    }
}

enum StatusRow: Int, TitledSection {
    case groups
    case subadmin
    case language
    case lastLogin
    case location
    case backend

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

    func rowData(_ userData: UserDataStruct) -> String {
        switch self {
        case .groups: return elementText(userData.groups?.element)
        case .subadmin: return elementText(userData.subadmin?.element)
        case .language: return fallbackText(userData.language)
        case .lastLogin: return userData.formattedLastLoginDate
        case .location: return fallbackText(userData.storageLocation)
        case .backend: return fallbackText(userData.backend)
        }
    }

    private func fallbackText(_ string: String?) -> String {
        return string ?? "N/A"
    }

    private func elementText(_ element: ElementContainer?) -> String {
        return fallbackText(element?.asJoinedString())
    }
}

enum GroupRole {
    case member, admin
}

enum Capabilities: Int, TitledSection {
    case displayName, password

    var title: String {
        switch self {
        case .displayName: return .localized(.setDisplayName)
        case .password: return .localized(.setPassword)
        }
    }

    func rowData(_ capabilities: BackendCapabilities) -> Bool {
        switch self {
        case .displayName: return capabilities.setDisplayName ?? false
        case .password: return capabilities.setPassword ?? false
        }
    }
}
