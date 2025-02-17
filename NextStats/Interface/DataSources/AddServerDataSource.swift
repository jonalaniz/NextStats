//
//  AddServerDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

enum LoginFields: Int, CaseIterable {
    case name = 0, url
}

class AuthenticationDataSource: NSObject, UITableViewDataSource {
    weak var textFieldDelegate: TextFieldDelegate?
    let dataManager: NXAuthenticator

    init(dataManager: NXAuthenticator) {
        self.dataManager = dataManager
        let delegate = TextFieldDelegate()
        textFieldDelegate = delegate
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LoginFields.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let field = LoginFields(rawValue: indexPath.row)
        else { return UITableViewCell() }

        let cell = InputCell(style: .default, reuseIdentifier: InputCell.reuseidentifier)
        configure(cell: cell, for: field)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return .localized(.addScreenLabel)
    }

    private func configure(cell: InputCell, for field: LoginFields) {
        let textField: UITextField
        switch field {
        case .name:
            textField = TextFieldFactory.textField(type: .normal,
                                                   placeholder: .localized(.addScreenNickname))
        case .url:
            textField = TextFieldFactory.textField(type: .URL,
                                                   placeholder: .localized(.addScreenUrl))
            textField.addTarget(dataManager,
                                action: #selector(dataManager.validateURL),
                                for: .editingChanged)
        }

        textField.delegate = textFieldDelegate
        cell.textField = textField
        cell.setup()
    }
}
