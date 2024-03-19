//
//  NewUsersCoordinator+TableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/17/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

enum NewUserFields: Int, CaseIterable {
    case name = 0, requiredFields, groups, sumAdmin, quota

    func sections() -> Int {
        switch self {
        case .name, .requiredFields: return 2
        case .groups, .sumAdmin, .quota: return 1
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
        case .groups:
            return UITableViewCell()
        case .sumAdmin:
            return UITableViewCell()
        case .quota:
            return UITableViewCell()
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

    func headerFor(section: NewUserFields) -> String {
        switch section {
        case .name: return ""
        case .requiredFields: return "Either a password or an email is required."
        case .groups: return "Groups"
        case .sumAdmin: return "Administered Groups"
        case .quota: return "Quota"
        }
    }
}

extension NewUserCoordinator: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
