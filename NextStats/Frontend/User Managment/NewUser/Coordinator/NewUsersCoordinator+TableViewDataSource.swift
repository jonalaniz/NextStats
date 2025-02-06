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

    var rowCount: Int {
        switch self {
        case .name, .requiredFields: return 2
        case .groups, .subAdmin, .quota: return 1
        }
    }

    var headerTitle: String {
        switch self {
        case .name: return ""
        case .requiredFields: return .localized(.requiredFields)
        case .groups: return .localized(.groups)
        case .subAdmin: return .localized(.setSubAdmin)
        case .quota: return .localized(.quota)
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
        return tableSection.rowCount
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
        case .groups: return groupSelectionCell(for: .member)
        case .subAdmin: return groupSelectionCell(for: .admin)
        case .quota: return quotaCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = NewUserFields(rawValue: section)
        else { return nil }

        return section.headerTitle
    }

    func nameCellFor(_ field: NameField) -> InputCell {
        switch field {
        case .username:
            return configureInputCell(
                placeholder: .localized(.usernameRequired),
                text: userFactory.userid,
                type: .normal,
                selector: #selector(updateUserid))
        case .displayName:
            return configureInputCell(
                placeholder: .localized(.displayName),
                text: userFactory.displayName,
                type: .normal,
                selector: #selector(updateDisplayName))
        }
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
        switch field {
        case .password:
            return configureInputCell(
                placeholder: .localized(.password),
                text: userFactory.password,
                type: .password,
                selector: #selector(updatePassword))
        case .email:
            return configureInputCell(
                placeholder: .localized(.email),
                text: userFactory.email,
                type: .email,
                selector: #selector(updateEmail))
        }
    }

    private func configureInputCell(placeholder: String,
                                    text: String?,
                                    type: TextFieldType,
                                    selector: Selector) -> InputCell {
        let cell = InputCell(style: .default, reuseIdentifier: "InputCell")
        let textField = TextFieldFactory.textField(type: type, placeholder: placeholder)
        textField.text = text
        textField.addTarget(self, action: selector, for: .editingChanged)
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

    func groupSelectionCell(for role: GroupRole) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        var content = cell.defaultContentConfiguration()

        guard userFactory.selectedGroupsFor(role: role).isEmpty else {
            content.text = userFactory.selectedGroupsFor(role: role).joined(separator: ", ")
            content.textProperties.color = .label
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator

            return cell
        }

        guard userFactory.groupsAvailable() != nil else {
            content.text = .localized(.noGroups)
            content.textProperties.color = .secondaryLabel
            cell.contentConfiguration = content
            cell.isUserInteractionEnabled = false

            return cell
        }

        content.text = .localized(.selectGroups)
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

    private func getInputCell(at indexPath: IndexPath) -> InputCell? {
        guard
            let tableView = newUserViewController.tableView,
            let cell = tableView.cellForRow(at: indexPath) as? InputCell
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
