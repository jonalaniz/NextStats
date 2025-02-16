//
//  NewUsersCoordinator+TableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/17/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension NewUserCoordinator: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewUserSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = NewUserSection(rawValue: section)
        else { return 0 }
        return tableSection.rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = NewUserSection(rawValue: indexPath.section)
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
        guard let section = NewUserSection(rawValue: section)
        else { return nil }

        return section.header
    }

    @objc func updateUserid() {
        let indexPath = IndexPath(row: NameField.username.rawValue,
                                  section: NewUserSection.name.rawValue)
        userFactory.set(userid: getInputCell(at: indexPath)?.textField.text)
        checkRequirements()
    }

    @objc func updateDisplayName() {
        let indexPath = IndexPath(row: NameField.displayName.rawValue,
                                  section: NewUserSection.name.rawValue)
        userFactory.set(displayName: getInputCell(at: indexPath)?.textField.text)
        checkRequirements()
    }

    func nameCellFor(_ field: NameField) -> InputCell {
        let (text, selector) =
        switch field {
        case .username: (userFactory.userid, #selector(updateUserid))
        case .displayName: (userFactory.displayName, #selector(updateDisplayName))
        }

        return configureInputCell(
            placeholder: field.placeholder,
            text: text,
            type: field.type,
            selector: selector)
    }

    func requiredCellFor(_ field: RequiredField) -> InputCell {
        let (text, selector) =
        switch field {
        case .password: (userFactory.password, #selector(updatePassword))
        case .email: (userFactory.email, #selector(updateEmail))
        }

        return configureInputCell(
            placeholder: field.placeholder,
            text: text,
            type: field.type,
            selector: selector)
    }

    private func configureInputCell(placeholder: String,
                                    text: String?,
                                    type: TextFieldType,
                                    selector: Selector) -> InputCell {
        let cell = InputCell(style: .default, reuseIdentifier: InputCell.reuseidentifier)
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
                                  section: NewUserSection.requiredFields.rawValue)
        userFactory.set(email: getInputCell(at: indexPath)?.textField.text)
        checkRequirements()
    }

    @objc func updatePassword() {
        let indexPath = IndexPath(row: RequiredField.password.rawValue,
                                  section: NewUserSection.requiredFields.rawValue)
        userFactory.set(password: getInputCell(at: indexPath)?.textField.text)
        checkRequirements()
    }

    func groupSelectionCell(for role: GroupRole) -> UITableViewCell {
        guard userFactory.selectedGroupsFor(role: role).isEmpty else {
            return BaseTableViewCell(style: .default,
                                     text: userFactory.selectedGroupsFor(role: role).joined(separator: ", "),
                                     accessoryType: .disclosureIndicator)
        }

        guard userFactory.groupsAvailable() != nil else {
            return BaseTableViewCell(style: .default,
                                     text: .localized(.noGroups),
                                     textColor: .secondaryLabel,
                                     isInteractive: false)
        }

        return BaseTableViewCell(style: .default,
                                 text: .localized(.selectGroups),
                                 textColor: .secondaryLabel,
                                 accessoryType: .disclosureIndicator)
    }

    func quotaCell() -> UITableViewCell {
        let quota = userFactory.quotaType()

        return BaseTableViewCell(style: .default,
                                 text: quota.rawValue,
                                 accessoryType: .disclosureIndicator)
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
