//
//  NXUserDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/1/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

enum MailCellType {
    case primary
    case additional
}

class NXUserDataManager: NSObject, UITableViewDataSource {
    /// Returns the shared `UserDataManager` instance
    public static let shared = NXUserDataManager()

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

    // MARK: - Functions for returning Cell Models for different sections
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

    func statusCell(_ row: Int, model: UserStatusModel) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "StatusCell")
        cell.textLabel?.textColor = .label
        cell.isUserInteractionEnabled = false

        switch row {
        case 0:
            let fixedTimeInt = model.lastlogin / 1000
            let date = Date(timeIntervalSince1970: TimeInterval(fixedTimeInt))
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short

            cell.textLabel?.text = "Last Login"
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        case 1:
            cell.textLabel?.text = "Location"
            cell.detailTextLabel?.text = model.storageLocation
        case 2:
            cell.textLabel?.text = "Backend"
            cell.detailTextLabel?.text = model.backend
        default:
            break
        }

        return cell
    }

    func userStatusCellModel(_ data: UserDataStruct) -> UserStatusModel {

        return UserStatusModel(backend: user?.data.backend ?? "",
                               lastlogin: user?.data.lastLogin ?? 0,
                               storageLocation: user?.data.storageLocation ?? "")
    }

    // MARK: - TableViewDataSource Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let user = user else { return 0 }

        switch section {
        case 0: return 3
        case 1:
            // Check if additionalMail element is present
            guard let additionalMail = user.data.additionalMail else { return 1 }

            // Check if additionaMail is a String or [String]
            guard let array = additionalMailArray() else { return 2 }

            // If there is an array, return the count plus 1 for the main email row.
            return array.count + 1

        case 2: return 1
        case 3: return 2
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let user else { return UITableViewCell() }

        switch indexPath.section {
        case 0:
            let statusModel = userStatusCellModel(user.data)
            return statusCell(indexPath.row, model: statusModel)
        // Email
        case 1:
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
        case 2:
            let cell = QuotaCell(style: .default, reuseIdentifier: "QuotaCell")
            cell.setProgress(with: user.data.quota)
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
        case 0: return "Status"
        case 1: return "Email"
        case 2:
            guard user.data.quota.quota! > 0 else {
                return "Quota (Unlimited)"
            }
            return "Quota"
        default: return nil
        }
    }
}

struct UserStatusModel {
    let backend: String
    let lastlogin: Int
    let storageLocation: String
}
