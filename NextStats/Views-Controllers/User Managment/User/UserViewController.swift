//
//  UserViewController.swift
//  UserViewController
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class UserViewController: UIViewController {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let userDataManager = UserDataManager.shared

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Here we will setup the new userDataManager
        setupView()
    }

    func setupView() {
        view.backgroundColor = .systemBackground
        title = userDataManager.title()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = userDataManager

        // Register our cells
        tableView.register(QuotaCell.self, forCellReuseIdentifier: "QuotaCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}

extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 66
        default: return 44
        }
    }
}

class UserDataManager: NSObject, UITableViewDataSource {
    /// Returns the shared `UserDataManager` instance
    public static let shared = UserDataManager()

    var user: User?

    func set(_ user: User) {
        self.user = user
    }

    func title() -> String {
        guard let user else { return "" }
        return user.data.displayname ?? ""
    }

    func additionalMailArray() -> [String]? {
        guard
            let user = user,
            let additionalMail = user.data.additionalMail
        else {
            return nil
        }

        switch additionalMail.element {
        case .stringArray(let array):
            return array
        default:
            return nil
        }
    }

    func mailCell(type: MailCellType, email: String?) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")

        switch type {
        case .primary:
            cell.textLabel?.textColor = .themeColor
        case .additional:
            break
        }

        cell.textLabel?.text = email ?? ""
        cell.isUserInteractionEnabled = false

        return cell
    }

    func email(from element: ElementContainer?) -> String? {
        switch element {
        case .string(let string):
            return string
        case .stringArray(let array):
            return array.first
        default:
            return nil
        }
    }

    func email(from element: ElementContainer?, at index: Int) -> String? {
        switch element {
        case .stringArray(let array):
            return array[index]
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let user = user else { return 0 }

        switch section {
        case 0:
            // Check if additionalMail element is present
            guard let additionalMail = user.data.additionalMail else { return 1 }

            // Check if additionaMail is a String or [String]
            guard let array = additionalMailArray() else { return 2 }

            // If there is an array, return the count plus 1 for the main email row.
            return array.count + 1

        case 1: return 1
        case 2: return 2
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user else { return UITableViewCell() }

        switch indexPath.section {
        // This is the email section
        case 0:
            switch indexPath.row {
            case 0:
                return mailCell(type: .primary, email: user.data.email)
            case 1:
                let email = email(from: user.data.additionalMail?.element)
                return mailCell(type: .additional, email: email)
            default:
                let email = email(from: user.data.additionalMail?.element, at: indexPath.row - 1)
                return mailCell(type: .additional, email: email)
            }
        // This can either be additional mail or something else
        case 1:
            let cell = QuotaCell(style: .default, reuseIdentifier: "QuotaCell")
            cell.setProgress(with: user.data.quota)
            cell.isUserInteractionEnabled = false
            return cell
        default:
            let cell = UITableViewCell()
            cell.textLabel?.backgroundColor = .red
            cell.textLabel?.text = "Test"
            cell.isUserInteractionEnabled = false
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let user = user else { return "" }

        switch section {
        case 0: return "Email"
        case 1:
            guard user.data.quota.quota! > 0 else {
                return "Quota Unlimited"
            }
            return "Quota"
        default: return nil
        }
    }
    // This manager will parse all the data and ensrue all data works in the tableView
}

enum MailCellType {
    case primary
    case additional
}
