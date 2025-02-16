//
//  UsersCoordinator+UITableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/16/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension UsersCoordinator: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = UserSection(rawValue: section)
        else { return 0 }

        switch tableSection {
        case .mail: return formatter.emailAddresses()?.count ?? 0
        case .quota: return 1
        case .status: return Status.allCases.count
        case .capabilities: return Capabilities.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let user = formatter.user,
            let tableSection = UserSection(rawValue: indexPath.section)
        else { return UITableViewCell() }

        switch tableSection {
        case .mail: return mailCell(in: indexPath.row, for: user)
        case .quota: return ProgressCell(quota: user.data.quota)
        case .status: return statusCell(indexPath.row)
        case .capabilities: return capabilitiesCell(indexPath.row)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return UserSection.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tableSection = UserSection(rawValue: section)
        else { return nil }

        switch tableSection {
        case .mail: return formatter.emailTitle()
        case .quota: return formatter.quotaTitle()
        case .status: return .localized(.status)
        case .capabilities: return .localized(.capabilities)
        }
    }

    func mailCell(in row: Int, for user: User) -> UITableViewCell {
        guard let emailAddresses = formatter.emailAddresses()
        else { return UITableViewCell() }

        return BaseTableViewCell(style: .default,
                                 text: emailAddresses[row],
                                 textColor: row == 0 ? .theme : .secondaryLabel)
    }

    func statusCell(_ row: Int) -> UITableViewCell {
        guard let status = Status(rawValue: row) else { return UITableViewCell() }
        let secondaryText: String

        switch status {
        case .groups: secondaryText = formatter.groups()
        case .subadmin: secondaryText = formatter.subadmin()
        case .language: secondaryText = formatter.language()
        case .lastLogin: secondaryText = formatter.lastLogonString()
        case .location: secondaryText = formatter.location()
        case .backend: secondaryText = formatter.backend()
        }

        return BaseTableViewCell(style: .value1,
                                 text: status.title,
                                 secondaryText: secondaryText)
    }

    func capabilitiesCell(_ row: Int) -> UITableViewCell {
        guard let capability = Capabilities(rawValue: row)
        else { return UITableViewCell() }

        var secondaryText: String?
        var accessoryType: UITableViewCell.AccessoryType = .none

        switch capability {
        case .displayName:
            formatter.canSetName() ? (accessoryType = .checkmark) : (secondaryText = .localized(.no))
        case .password:
            formatter.canSetPassword() ? (accessoryType = .checkmark) : (secondaryText = .localized(.no))
        }

        return BaseTableViewCell(style: .value1,
                                 text: capability.title,
                                 secondaryText: secondaryText,
                                 accessoryType: accessoryType)
    }
}
