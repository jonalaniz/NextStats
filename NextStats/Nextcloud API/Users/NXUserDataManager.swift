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

class NXUserDataManager: NSObject {
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

    func emailAddresses() -> [String]? {
        guard
            let user = user,
            let mainAddress = user.data.email
        else {
            return nil
        }

        var emails = [mainAddress]

        guard
            let additionalMail = user.data.additionalMail
        else {
            return emails
        }

        switch additionalMail.element {
        case .string(let address):
            emails.append(address)
        case .stringArray(let array):
            emails.append(contentsOf: array)
        case .none:
            return emails
        }

        return emails
    }

    func lastLogonString() -> String {
        guard let dateInt = user?.data.lastLogin else {
            return "N/A"
        }

        let correctedDateInt = dateInt / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(correctedDateInt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        return dateFormatter.string(from: date)
    }

    func backend() -> String {
        return user?.data.backend ?? "N/A"
    }

    func location() -> String {
        return user?.data.storageLocation ?? "N/A"
    }

    func emailTitle() -> String? {
        guard emailAddresses() != nil else { return "No Email on File"}
        return "Email"
    }

    func quotaTitle() -> String? {
        guard
            let user = user,
            let quota = user.data.quota.quota
        else { return nil }

        var string = ""

        (quota > 0) ? (string = "Quota (Unlimited)") : (string = "Quota")

        return string
    }
}
