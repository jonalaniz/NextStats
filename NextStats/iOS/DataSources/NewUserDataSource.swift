//
//  NewUserDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

final class NewUserDataSource: NSObject, UITableViewDataSource {

    // MARK: - Properties
    let userFactory = NXUserFactory.shared
    var textFieldDelegate = TextFieldDelegate.shared

    func numberOfSections(in tableView: UITableView) -> Int {
        return NewUserSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = NewUserSection(rawValue: section)
        else { return 0 }
        return NewUserItem.items(for: tableSection).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = NewUserSection(rawValue: indexPath.section)
        else { return UITableViewCell() }

        let item = NewUserItem.items(for: tableSection)[indexPath.row]

        switch tableSection {
        case .name, .requiredFields: return makeInputCell(for: item)
        case .groups: return makeGroupCell(for: .member)
        case .subAdmin: return makeGroupCell(for: .admin)
        case .quota: return makeQuotaCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = NewUserSection(rawValue: section)
        else { return nil }

        return section.header
    }

    // MARK: - Cell Creation

    private func makeInputCell(for userItem: NewUserItem) -> InputCell {
        let cell = InputCell(style: .default)
        let textField = TextFieldFactory.textField(
            type: userItem.type,
            placeholder: userItem.placeholder
        )

        textField.text = text(for: userItem)
        textField.addTarget(
            self,
            action: #selector(applyInput),
            for: .editingChanged
        )
        textField.delegate = textFieldDelegate
        if let tag = userItem.tag { textField.tag = tag }

        cell.textField = textField
        cell.setup()
        return cell
    }

    private func makeGroupCell(for role: GroupRole) -> UITableViewCell {
        guard userFactory.availableGroupNames() != nil else {
            return BaseTableViewCell(
                style: .default,
                text: .localized(.noGroups),
                textColor: .secondaryLabel,
                isInteractive: false
            )
        }

        let isEmpty = userFactory.selectedGroupsFor(role) == nil
        let color: UIColor = isEmpty ? .secondaryLabel : .label
        let text = userFactory.selectedGroupsStringFor(role) ?? .localized(.selectGroups)

        return BaseTableViewCell(
            style: .default,
            text: text,
            textColor: color,
            accessoryType: .disclosureIndicator
        )
    }

    private func makeQuotaCell() -> UITableViewCell {
        return BaseTableViewCell(
            style: .default,
            text: userFactory.quotaType().displayName,
            accessoryType: .disclosureIndicator
        )
    }

    // MARK: - Helper Methods

    @objc private func applyInput(_ sender: UITextField) {
        guard
            let item = NewUserItem(from: sender.tag),
            let text = sender.text
        else { return }

        switch item {
        case .username: userFactory.set(userid: text)
        case .displayName: userFactory.set(displayName: text)
        case .email: userFactory.set(email: text)
        case .password: userFactory.set(password: text)
        default: break
        }

        userFactory.checkRequirements()
    }

    private func text(for field: NewUserItem) -> String? {
        switch field {
        case .username: return userFactory.userid
        case .displayName: return userFactory.displayName
        case .email: return userFactory.email
        case .password: return userFactory.password
        default: return nil
        }
    }
}
