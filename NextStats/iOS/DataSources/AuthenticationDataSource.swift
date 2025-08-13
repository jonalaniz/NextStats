//
//  AuthenticationDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

protocol AuthenticationDataSourceDelegate: AnyObject {
    func didEnterURL(_ url: String)
}

final class AuthenticationDataSource: NSObject, UITableViewDataSource {
    weak var delegate: AuthenticationDataSourceDelegate?

    private let textFieldDelegate = TextFieldDelegate.shared
    private var url: String?
    private var name: String?

    func tableView(
        _ tableView: UITableView, numberOfRowsInSection section: Int
    ) -> Int {
        return LoginItem.allCases.count
    }

    func tableView(
        _ tableView: UITableView, titleForFooterInSection section: Int
    ) -> String? {
        return .localized(.addScreenLabel)
    }

    func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let item = LoginItem(rawValue: indexPath.row)
        else { return UITableViewCell() }

        return makeCell(for: item)
    }

    // MARK: - Cell Creation

    private func makeCell(for item: LoginItem) -> InputCell {
        let cell = InputCell(style: .default)

        let textField = TextFieldFactory.textField(
            type: item.type,
            placeholder: item.placeholder
        )

        textField.addTarget(
            self,
            action: #selector(applyInput),
            for: .editingChanged
        )

        textField.tag = item.tag
        textField.delegate = textFieldDelegate
        cell.textField = textField
        cell.setup()

        return cell
    }

    // MARK: - Helper Methods

    @objc private func applyInput(_ sender: UITextField) {
        guard
            let item = LoginItem(from: sender.tag),
            let text = sender.text
        else { return }

        switch item {
        case .name: name = text
        case .url:
            url = text
            delegate?.didEnterURL(url ?? "")
        }
    }
}
