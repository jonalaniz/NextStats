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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "StatusCell")
        cell.isUserInteractionEnabled = false

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .theme
        content.secondaryTextProperties.color = .secondaryLabel

        switch row {
        case 0:
            content.text = "Groups"
            content.secondaryText = formatter.groups()
        case 1:
            content.text = "SubAdmin"
            content.secondaryText = formatter.subadmin()
        case 2:
            content.text = .localized(.language)
            content.secondaryText = formatter.language()
        case 3:
            content.text = .localized(.lastLogin)
            content.secondaryText = formatter.lastLogonString()
        case 4:
            content.text = .localized(.location)
            content.secondaryText = formatter.location()
        case 5:
            content.text = .localized(.backend)
            content.secondaryText = formatter.backend()
        default:
            break
        }

        cell.contentConfiguration = content
        return cell
    }

    // Capabilities
    func capabilitiesCell(_ row: Int) -> UITableViewCell {
        guard let cellType = CapabilitiesCellType(rawValue: row)
        else { return UITableViewCell() }

        let cell = UITableViewCell(style: .value1, reuseIdentifier: "StatusCell")
        cell.isUserInteractionEnabled = false

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .theme
        content.secondaryTextProperties.color = .secondaryLabel

        switch cellType {
        case .displayName:
            content.text = .localized(.setDisplayName)
            formatter.canSetName() ? (cell.accessoryType = .checkmark) : (content.secondaryText = .localized(.no))
        case .password:
            content.text = .localized(.setPassword)
            formatter.canSetPassword() ? (cell.accessoryType = .checkmark) : (content.secondaryText = .localized(.no))
        }

        cell.contentConfiguration = content
        return cell
    }
}
