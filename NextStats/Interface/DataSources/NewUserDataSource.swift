//
//  NewUserDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserDataSource: NSObject, UITableViewDataSource {
    let userFactory: NXUserFactory
    weak var textFieldDelegate: TextFieldDelegate?

    // Dictionary to hold textFields mapped to their indexPath
    private var textFields: [IndexPath: UITextField] = [:]

    init(userFactory: NXUserFactory) {
        self.userFactory = userFactory
        let delegate = TextFieldDelegate()
        textFieldDelegate = delegate
    }

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
            return nameCellFor(row, indexPath: indexPath)
        case .requiredFields:
            guard let row = RequiredField(rawValue: indexPath.row)
            else { return UITableViewCell() }
            return requiredCellFor(row, indexPath: indexPath)
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

    func nameCellFor(_ field: NameField, indexPath: IndexPath) -> InputCell {
        let text =
        switch field {
        case .username: userFactory.userid
        case .displayName: userFactory.displayName
        }

        return configureInputCell(
            placeholder: field.placeholder,
            text: text,
            type: field.type,
            indexPath: indexPath)
    }

    func requiredCellFor(_ field: RequiredField, indexPath: IndexPath) -> InputCell {
        let text =
        switch field {
        case .password: userFactory.password
        case .email: userFactory.email
        }

        return configureInputCell(
            placeholder: field.placeholder,
            text: text,
            type: field.type,
            indexPath: indexPath)
    }

    private func configureInputCell(placeholder: String,
                                    text: String?,
                                    type: TextFieldType,
                                    indexPath: IndexPath) -> InputCell {
        let cell = InputCell(style: .default, reuseIdentifier: InputCell.reuseidentifier)
        let textField = TextFieldFactory.textField(type: type, placeholder: placeholder)

        textField.text = text
        textField.delegate = textFieldDelegate
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // Store the textField with indexPath
        textFields[indexPath] = textField

        cell.textField = textField
        cell.setup()
        return cell
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

    @objc private func textFieldDidChange(_ sender: UITextField) {
        // Find the indexPath for this textField
        guard let indexPath = textFields.first(where: { $0.value == sender})?.key
        else { return }

        // Map indexPath.section to the NewUsersSection
        guard let section = NewUserSection(rawValue: indexPath.section)
        else { return }

        switch section {
        case .name: updateNameField(indexPath.row, with: sender.text)
        case .requiredFields: updateRequiredField(indexPath.row, with: sender.text)
        default: return
        }
    }

    private func updateNameField(_ row: Int, with text: String?) {
        // Map the row to a field
        guard let field = NameField(rawValue: row),
              let text = text
        else { return }

        switch field {
        case .username: userFactory.set(userid: text)
        case .displayName: userFactory.set(displayName: text)
        }

        userFactory.checkRequirements()
    }

    private func updateRequiredField(_ row: Int, with text: String?) {
        // Map the row to a field
        guard let field = RequiredField(rawValue: row),
              let text = text
        else { return }

        switch field {
        case .email: userFactory.set(email: text)
        case .password: userFactory.set(password: text)
        }

        userFactory.checkRequirements()
    }
}
