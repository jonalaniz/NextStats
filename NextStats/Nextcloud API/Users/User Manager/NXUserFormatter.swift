//
//  NXUserDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/1/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class NXUserFormatter: NSObject {
    /// Returns the shared `UserDataManager` instance
    public static let shared = NXUserFormatter()

    var user: User?

    func set(_ user: User) {
        self.user = user
    }

    func userID() -> String {
        guard let user else { return "" }
        return user.data.id
    }

    func enabled() -> Bool {
        guard let user else { return false }
        return user.data.enabled
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
        case .string(let address): emails.append(address)
        case .stringArray(let array): emails.append(contentsOf: array)
        case .none: return emails
        }

        return emails
    }

    func groups() -> String {
        guard let groups = user?.data.groups
        else { return "" }

        switch groups.element {
        case .string(let string): return string
        case .stringArray(let array): return array.joined(separator: ", ")
        case .none: return "N/A"
        }
    }

    func subadmin() -> String {
        guard let subadmin = user?.data.subadmin
        else { return "N/A" }

        switch subadmin.element {
        case .string(let string): return string
        case .stringArray(let array): return array.joined(separator: ", ")
        case .none: return "N/A"
        }
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

    func language() -> String {
        return user?.data.language ?? "N/A"
    }

    func location() -> String {
        return user?.data.storageLocation ?? "N/A"
    }

    func emailTitle() -> String? {
        guard emailAddresses() != nil else { return .localized(.usersNoEmail)}
        return .localized(.usersEmail)
    }

    func quotaTitle() -> String? {
        guard
            let user = user,
            let quota = user.data.quota.quota
        else { return nil }

        var string = ""

        switch quota {
        case .int(let quotaInt):
            (quotaInt > 0) ? (string = .localized(.quota)) : (string = .localized(.quotaUnlimited))
        case .string(let quotaString):
            string = quotaString
        }

        return string
    }

    func canSetName() -> Bool {
        return user?.data.backendCapabilities.setDisplayName ?? false
    }

    func canSetPassword() -> Bool {
        return user?.data.backendCapabilities.setPassword ?? false
    }
}
