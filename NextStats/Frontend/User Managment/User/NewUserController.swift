//
//  NewUserController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/15/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserController: UIViewController {
    weak var coordinator: UsersCoordinator?

    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupView()
    }

    private func setupNavigationController() {
        title = "New User"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupView() {
        tableView.register(InputCell.self, forCellReuseIdentifier: "InputCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}

//class NewUserFactory {
//    // We need to import a server
//    var server: NextServer
//
//    // We need to get the server groups
//
//    // We need to create the server
//
//    // Before we send the request we *Need* either an email or password set
//}

extension NewUserController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewUserFields.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
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
            return UITableViewCell()
        case .groups:
            return UITableViewCell()
        case .sumAdmin:
            return UITableViewCell()
        case .quota:
            return UITableViewCell()
        }
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
            placeholder = "Username (required)"
            type = .password
        case .email:
            placeholder = "Display name"
            type = .email
        }
        let cell = InputCell(style: .default, reuseIdentifier: "InputCell")
        let textField = TextFieldFactory.textField(type: .normal,
                                                   placeholder: placeholder)
        textField.delegate = self
        cell.textField = textField
        cell.setup()

        return cell
    }
}

extension NewUserController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

protocol NewUserFactoryDelegate {
    func success()
    func fail(statusCode: Int)
    func missingRequired(field: RequiredField)
}

enum NameField: Int, CaseIterable {
    case username = 0, displayName
}

enum RequiredField: Int, CaseIterable {
    case email = 0, password
}

enum NewUserFields: Int, CaseIterable {
    case name = 0, requiredFields, groups, sumAdmin, quota

    func sections() -> Int {
        switch self {
        case .name, .requiredFields: return 2
        case .groups, .sumAdmin, .quota: return 1
        }
    }
}

//Status codes:
//
//100 - successful
//101 - invalid input data
//102 - username already exists
//103 - unknown error occurred whilst adding the user
//104 - group does not exist
//105 - insufficient privileges for group
//106 - no group specified (required for subadmins)
//107 - all errors that contain a hint - for example “Password is among the 1,000,000 most common ones. Please make it unique.” (this code was added in 12.0.6 & 13.0.1)
//108 - password and email empty. Must set password or an email
//109 - invitation email cannot be send
