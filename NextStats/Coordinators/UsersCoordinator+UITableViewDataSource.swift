//
//  UsersCoordinator+UITableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/16/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

enum MailCellType {
    case primary, additional
}

enum CapabilitiesCellType: Int, CaseIterable {
    case displayName, password
}

enum UserDataSection: Int, CaseIterable {
    case mail = 0, quota, status, capabilities

    func height() -> CGFloat {
        switch self {
        case .quota: return 66
        default: return 44
        }
    }
}

extension UsersCoordinator: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = UserDataSection(rawValue: section)
        else { return 0 }

        switch tableSection {
        case .mail: return formatter.emailAddresses()?.count ?? 0
        case .quota: return 1
        case .status: return 6
        case .capabilities: return 2
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let user = formatter.user,
            let tableSection = UserDataSection(rawValue: indexPath.section)
        else { return UITableViewCell() }

        switch tableSection {
        case .mail: return mailSection(in: indexPath.row, for: user)
        case .quota: return ProgressCell(quota: user.data.quota)
        case .status: return statusCell(indexPath.row)
        case .capabilities: return capabilitiesCell(indexPath.row)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return UserDataSection.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tableSection = UserDataSection(rawValue: section)
        else { return nil }

        switch tableSection {
        case .mail: return formatter.emailTitle()
        case .quota: return formatter.quotaTitle()
        case .status: return .localized(.status)
        case .capabilities: return .localized(.capabilities)
        }
    }

    // Email
    func mailSection(in row: Int, for user: User) -> UITableViewCell {
        guard let emailAddresses = formatter.emailAddresses()
        else { return UITableViewCell() }

        switch row {
        case 0:
            return mailCell(type: .primary, email: emailAddresses[row])
        default:
            return mailCell(type: .additional, email: emailAddresses[row])
        }
    }

    func mailCell(type: MailCellType, email: String?) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.isUserInteractionEnabled = false

        var content = cell.defaultContentConfiguration()

        switch type {
        case .primary:
            content.textProperties.color = .theme
        case .additional:
            content.textProperties.color = .secondaryLabel
        }

        content.text = email ?? ""
        cell.contentConfiguration = content

        return cell
    }

    // Status
    func statusCell(_ row: Int) -> UITableViewCell {
        let text: String
        let secondaryText: String

        switch row {
        case 0:
            text = "Groups"
            secondaryText = formatter.groups()
        case 1:
            text = "SubAdmin"
            secondaryText = formatter.subadmin()
        case 2:
            text = .localized(.language)
            secondaryText = formatter.language()
        case 3:
            text = .localized(.lastLogin)
            secondaryText = formatter.lastLogonString()
        case 4:
            text = .localized(.location)
            secondaryText = formatter.location()
        case 5:
            text = .localized(.backend)
            secondaryText = formatter.backend()
        default: return UITableViewCell()
        }

        return usersCell(style: .value1,
                         reuseIdentifier: "StatusCell",
                         text: text,
                         secondaryText: secondaryText)
    }

    // Capabilities
    func capabilitiesCell(_ row: Int) -> UITableViewCell {
        guard let cellType = CapabilitiesCellType(rawValue: row)
        else { return UITableViewCell() }

        let text: String
        var secondaryText: String?
        var accessoryType: UITableViewCell.AccessoryType = .none

        switch cellType {
        case .displayName:
            text = .localized(.setDisplayName)
            formatter.canSetName() ? (accessoryType = .checkmark) : (secondaryText = .localized(.no))
        case .password:
            text = .localized(.setPassword)
            formatter.canSetPassword() ? (accessoryType = .checkmark) : (secondaryText = .localized(.no))
        }

        return usersCell(style: .value1,
                         reuseIdentifier: "StatusCell",
                         text: text,
                         secondaryText: secondaryText,
                         accessoryType: accessoryType)
    }

    private func usersCell(style: UITableViewCell.CellStyle,
                           reuseIdentifier: String,
                           text: String,
                           secondaryText: String? = nil,
                           isInteractive: Bool = false,
                           accessoryType: UITableViewCell.AccessoryType = .none) -> UITableViewCell {
        let cell = UITableViewCell(style: style, reuseIdentifier: reuseIdentifier)
        cell.isUserInteractionEnabled = isInteractive
        cell.accessoryType = accessoryType

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .theme
        content.secondaryTextProperties.color = .secondaryLabel
        content.text = text
        content.secondaryText = secondaryText
        cell.contentConfiguration = content
        return cell
    }
}
