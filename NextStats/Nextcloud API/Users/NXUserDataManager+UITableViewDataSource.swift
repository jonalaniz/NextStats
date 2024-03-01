//
//  NXUserDataManager+UITableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/13/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

enum MailCellType {
    case primary
    case additional
}

extension NXUserDataManager: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return emailAddresses()?.count ?? 0
        case 1: return 1
        case 2: return 4
        case 3: return 2
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            return mailSection(in: indexPath.row, for: user)
        case 1:
            return StorageCell(reuseIdentifier: "QuotaCell",
                             quota: user.data.quota)
        case 2:
            return statusCell(indexPath.row)
        case 3:
            return capabilitiesCell(indexPath.row)
        default:
            return UITableViewCell()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return emailTitle()
        case 1: return quotaTitle()
        case 2: return .localized(.status)
        case 3: return .localized(.status)
        default: return nil
        }
    }

    // MARK: - UITableViewDelegate Functions
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldHide(section: section) ? CGFloat.leastNonzeroMagnitude : 20
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 66
        default: return 44
        }
    }

    // MARK: - Helper Functions

    func shouldHide(section: Int) -> Bool {
        switch section {
        case 0: return emailAddresses() == nil
        default: return false
        }
    }

    // Email
    func mailSection(in row: Int, for user: User) -> UITableViewCell {
        guard let emailAddresses = emailAddresses() else { return UITableViewCell() }

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
            content.textProperties.color = .themeColor
        case .additional:
            content.textProperties.color = .label
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
        content.textProperties.color = .label

        switch row {
        case 0:
            content.text = .localized(.language)
            content.secondaryText = language()
        case 1:
            content.text = .localized(.lastLogin)
            content.secondaryText = lastLogonString()
        case 2:
            content.text = .localized(.location)
            content.secondaryText = location()
        case 3:
            content.text = .localized(.backend)
            content.secondaryText = backend()
        default:
            break
        }

        cell.contentConfiguration = content
        return cell
    }

    // Capabilities
    func capabilitiesCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "StatusCell")
        cell.isUserInteractionEnabled = false

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .label

        switch row {
        case 0:
            content.text = .localized(.setDisplayName)
            canSetDisplayName() ? (cell.accessoryType = .checkmark) : (content.secondaryText = .localized(.no))
        case 1:
            content.text = .localized(.setPassword)
            canSetPassword() ? (cell.accessoryType = .checkmark) : (content.secondaryText = .localized(.no))
        default:
            break
        }

        cell.contentConfiguration = content
        return cell
    }
}
