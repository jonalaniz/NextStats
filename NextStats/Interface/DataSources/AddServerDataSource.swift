//
//  AddServerDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

protocol AuthenticationDataSourceDelegate: AnyObject {
    func didEnterURL(_ url: String)
}

class AuthenticationDataSource: NSObject, UITableViewDataSource {
    weak var delegate: AuthenticationDataSourceDelegate?
    private let textFieldDelegate = TextFieldDelegate()
    var url: String?
    var name: String?

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return LoginFields.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let field = LoginFields(rawValue: indexPath.row)
        else { return UITableViewCell() }

        let cell = InputCell(
            style: .default,
            reuseIdentifier: InputCell.reuseidentifier)
        configure(cell: cell, for: field)

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        titleForFooterInSection section: Int
    ) -> String? {
        return .localized(.addScreenLabel)
    }

    private func configure(cell: InputCell, for field: LoginFields) {
        let textField: UITextField
        switch field {
        case .name:
            textField = TextFieldFactory.textField(
                type: .normal,
                placeholder: .localized(.addScreenNickname)
            )
        case .url:
            textField = TextFieldFactory.textField(
                type: .URL,
                placeholder: .localized(.addScreenUrl)
            )
        }
        textField.addTarget(
            self,
            action: #selector(urlTextChanged),
            for: .editingChanged
        )
        textField.tag = field.rawValue
        textField.delegate = textFieldDelegate
        cell.textField = textField
        cell.setup()
    }

    @objc private func urlTextChanged(_ sender: UITextField) {
        guard let field = LoginFields(rawValue: sender.tag)
        else { return }
        switch field {
        case .name: name = sender.text
        case .url:
            url = sender.text
            delegate?.didEnterURL(sender.text ?? "")
        }
    }
}
