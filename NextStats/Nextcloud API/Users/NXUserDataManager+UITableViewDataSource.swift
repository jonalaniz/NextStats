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

extension NXUserDataManager: UITableViewDataSource {
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
            return QuotaCell(reuseIdentifier: "QuotaCell",
                             quota: user.data.quota)
        case 2:
            return statusCell(indexPath.row)
        case 3:
            return capabilitiesCell(indexPath.row)
        default:
            let cell = UITableViewCell()
            cell.textLabel?.backgroundColor = .red
            cell.textLabel?.text = "Test"
            cell.isUserInteractionEnabled = false
            return cell
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

    // MARK: - Helper Functions

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

        switch type {
        case .primary:
            cell.textLabel?.textColor = .themeColor
        case .additional:
            break
        }

        cell.textLabel?.text = email ?? ""
        cell.isUserInteractionEnabled = false

        return cell
    }

    // Status
    func statusCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "StatusCell")
        cell.textLabel?.textColor = .label
        cell.isUserInteractionEnabled = false

        switch row {
        case 0:
            cell.textLabel?.text = .localized(.language)
            cell.detailTextLabel?.text = language()
        case 1:
            cell.textLabel?.text = .localized(.lastLogin)
            cell.detailTextLabel?.text = lastLogonString()
        case 2:
            cell.textLabel?.text = .localized(.location)
            cell.detailTextLabel?.text = location()
        case 3:
            cell.textLabel?.text = .localized(.backend)
            cell.detailTextLabel?.text = backend()
        default:
            break
        }

        return cell
    }

    // Capabilities
    func capabilitiesCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "StatusCell")
        cell.textLabel?.textColor = .label
        cell.isUserInteractionEnabled = false

        switch row {
        case 0:
            cell.textLabel?.text = .localized(.setDisplayName)
            canSetDisplayName() ? (cell.accessoryType = .checkmark) : (cell.detailTextLabel?.text = .localized(.no))
        case 1:
            cell.textLabel?.text = .localized(.setPassword)
            canSetPassword() ? (cell.accessoryType = .checkmark) : (cell.detailTextLabel?.text = .localized(.no))
        default:
            break
        }

        return cell
    }
}
