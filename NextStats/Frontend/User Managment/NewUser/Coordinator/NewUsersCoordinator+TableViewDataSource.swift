//
//  NewUsersCoordinator+TableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/17/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

enum NewUserFields: Int, CaseIterable {
    case name = 0, requiredFields, groups, subAdmin
//         quota

    func sections() -> Int {
        switch self {
        case .name, .requiredFields: return 2
        case .groups, .subAdmin: return 1
        }
    }
}

enum NameField: Int, CaseIterable {
    case username = 0, displayName
}

enum RequiredField: Int, CaseIterable {
    case email = 0, password
}

enum QuotaTypes: Int, CaseIterable {
    case defaultQuota, unlimited, oneGB, fiveGB, tenGB
}

extension NewUserCoordinator: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewUserFields.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = NewUserFields(rawValue: section)
        else { return 0 }
        return tableSection.sections()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = NewUserFields(rawValue: indexPath.section)
        else { return UITableViewCell() }

        switch tableSection {
        case .name:
            guard let row = NameField(rawValue: indexPath.row)
            else { return UITableViewCell() }
            return nameCellFor(row)
        case .requiredFields:
            guard let row = RequiredField(rawValue: indexPath.row)
            else { return UITableViewCell() }
            return requiredCellFor(row)
        case .groups: return groupsCell()
        case .subAdmin: return subAdminCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = NewUserFields(rawValue: section)
        else { return nil }

        return headerFor(section: section)
    }

    func nameCellFor(_ field: NameField) -> InputCell {
        let placeholder: String

        switch field {
        case .username: placeholder = "Username (required)"
        case .displayName: placeholder = "Display name"
        }
        let cell = InputCell(style: .default, reuseIdentifier: "InputCell")
        let textField = TextFieldFactory.textField(type: .normal,
                                                   placeholder: placeholder)
        textField.delegate = self
        cell.textField = textField
        cell.setup()

        return cell
    }

    func requiredCellFor(_ field: RequiredField) -> InputCell {
        let placeholder: String
        let type: TextFieldType

        switch field {
        case .password:
            placeholder = "Password"
            type = .password
        case .email:
            placeholder = "Email"
            type = .email
        }
        let cell = InputCell(style: .default, reuseIdentifier: "InputCell")
        let textField = TextFieldFactory.textField(type: type,
                                                   placeholder: placeholder)
        textField.delegate = self
        cell.textField = textField
        cell.setup()

        return cell
    }

    func groupsCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        var content = cell.defaultContentConfiguration()

        guard userFactory.selectedGroupsFor(role: .member).isEmpty else {
            content.text = userFactory.selectedGroupsFor(role: .member).joined(separator: ", ")
            content.textProperties.color = .label
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator

            return cell
        }

        guard let groups = userFactory.groupsAvailable() else {
            content.text = "No groups available"
            content.textProperties.color = .secondaryLabel
            cell.contentConfiguration = content
            cell.isUserInteractionEnabled = false

            return cell
        }

        content.text = "Select groups"
        content.textProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func subAdminCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        var content = cell.defaultContentConfiguration()

        guard userFactory.selectedGroupsFor(role: .admin).isEmpty else {
            content.text = userFactory.selectedGroupsFor(role: .admin).joined(separator: ", ")
            content.textProperties.color = .label
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator

            return cell
        }

        guard let groups = userFactory.groupsAvailable() else {
            content.text = "No groups available"
            content.textProperties.color = .secondaryLabel
            cell.contentConfiguration = content
            cell.isUserInteractionEnabled = false

            return cell
        }

        content.text = "Select groups"
        content.textProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func headerFor(section: NewUserFields) -> String {
        switch section {
        case .name: return ""
        case .requiredFields: return "Email or password required."
        case .groups: return "Groups"
        case .subAdmin: return "Set group admin for"
        }
    }
}

extension NewUserCoordinator: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
