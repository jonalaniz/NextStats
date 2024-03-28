//
//  NewUsersCoordinator+TableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/17/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

enum NewUserFields: Int, CaseIterable {
    case name = 0, requiredFields, groups, subAdmin, quota

    func sections() -> Int {
        switch self {
        case .name, .requiredFields: return 2
        case .groups, .subAdmin, .quota: return 1
        }
    }
}

enum NameField: Int, CaseIterable {
    case username = 0, displayName
}

enum RequiredField: Int, CaseIterable {
    case email = 0, password
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
        case .quota: return quotaCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = NewUserFields(rawValue: section)
        else { return nil }

        return headerFor(section: section)
    }

    func nameCellFor(_ field: NameField) -> InputCell {
        let placeholder: String
        let selector: Selector

        switch field {
        case .username:
            placeholder = "Username (required)"
            selector = #selector(updateUserid)
        case .displayName:
            placeholder = "Display name"
            selector = #selector(updateDisplayName)
        }
        let cell = InputCell(style: .default, reuseIdentifier: "InputCell")
        let textField = TextFieldFactory.textField(type: .normal,
                                                   placeholder: placeholder)
        textField.addTarget(self, action: selector, for: .editingChanged)
        textField.delegate = self
        cell.textField = textField
        cell.setup()

        return cell
    }

    @objc func updateUserid() {
        let indexPath = IndexPath(row: NameField.username.rawValue,
                                  section: NewUserFields.name.rawValue)
        userFactory.set(userid: getInputCell(at: indexPath)?.textField.text)
        checkRequirements()
    }

    @objc func updateDisplayName() {
        let indexPath = IndexPath(row: NameField.displayName.rawValue,
                                  section: NewUserFields.name.rawValue)
        userFactory.set(displayName: getInputCell(at: indexPath)?.textField.text)
        checkRequirements()
    }

    func requiredCellFor(_ field: RequiredField) -> InputCell {
        let placeholder: String
        let type: TextFieldType
        let selector: Selector

        switch field {
        case .password:
            placeholder = "Password"
            selector = #selector(updatePassword)
            type = .password
        case .email:
            placeholder = "Email"
            selector =  #selector(updateEmail)
            type = .email
        }
        let cell = InputCell(style: .default, reuseIdentifier: "InputCell")
        let textField = TextFieldFactory.textField(type: type,
                                                   placeholder: placeholder)
        textField.addTarget(self, action: selector, for: .allEditingEvents)
        textField.delegate = self
        cell.textField = textField
        cell.setup()

        return cell
    }

    @objc func updateEmail() {
        let indexPath = IndexPath(row: RequiredField.email.rawValue,
                                  section: NewUserFields.requiredFields.rawValue)
        userFactory.set(email: getInputCell(at: indexPath)?.textField.text)
        checkRequirements()
    }

    @objc func updatePassword() {
        let indexPath = IndexPath(row: RequiredField.password.rawValue,
                                  section: NewUserFields.requiredFields.rawValue)
        userFactory.set(password: getInputCell(at: indexPath)?.textField.text)
        checkRequirements()
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

        guard userFactory.groupsAvailable() != nil else {
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

        guard userFactory.groupsAvailable() != nil else {
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

    func quotaCell() -> UITableViewCell {
        let quota = userFactory.quotaType()
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        var content = cell.defaultContentConfiguration()

        content.text = quota.rawValue
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
        case .quota: return "Quota"
        }
    }

    private func getInputCell(at indexPath: IndexPath) -> InputCell? {
        let tableView = newUserViewController.tableView
        guard let cell = tableView.cellForRow(at: indexPath) as? InputCell
        else { return nil }

        return cell
    }

    private func checkRequirements() {
        guard userFactory.requirementsMet() else { return }

        newUserViewController.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension NewUserCoordinator: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
