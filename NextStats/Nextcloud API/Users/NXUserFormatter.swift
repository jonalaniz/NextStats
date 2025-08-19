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

    weak var delegate: NXDataManagerDelegate?

    var user: User?

    func emailAddresses() -> [String]? {
        guard
            let user = user,
            let mainAddress = user.data.email
        else { return nil }

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

    func buildTableData(for user: User) -> [TableSection] {
        self.user = user

        // Quota Section
        let quotaSection = TableSection(
            title: UserSection.quota.header(
                emails: nil,
                quota: user.data.quota.quota
            ),
            rows: quotaSection()
        )

        // Status Section
        let statusSection = TableSection(
            title: UserSection.status.header(emails: nil, quota: nil),
            rows: statusSection()
        )

        // Capabilities Section
        let capabilitiesSection = TableSection(
            title: UserSection.capabilities.header(
                emails: nil,
                quota: nil),
            rows: capabilitiesSection()
        )

        // Email section done last as may be empty
        guard let addresses = emailAddresses()
        else {
            return [quotaSection, statusSection, capabilitiesSection]
        }

        let emailSection = TableSection(
            title: UserSection.mail.header(
                emails: addresses,
                quota: nil
            ),
            rows: emailSection(addresses)
        )

        // Return data
        return [
            emailSection, quotaSection, statusSection, capabilitiesSection
        ]
    }

    private func emailSection(_ addresses: [String]) -> [TableRow] {
        return addresses.enumerated().map { index, address in
            let color = index == 0 ? UIColor.theme : .secondaryLabel
            return TableRow(
                title: address,
                titleColor: color,
                secondaryText: nil
            )
        }
    }

    private func quotaSection() -> [TableRow] {
        guard
            case let .int(quota) = user?.data.quota.quota,
            let used = user?.data.quota.used,
            let total = user?.data.quota.total
        else {
            return [TableRow(title: "Quota", secondaryText: nil)]
        }

        let free = total - used
        let usedString = Units(bytes: used).readableUnit
        let totalString = Units(bytes: total).readableUnit

        let quotaString: String
        if quota < 0 {
            quotaString = "\(usedString) of \(totalString) Used"
        } else {
            let quotaUnit = Units(bytes: quota).readableUnit
            quotaString = "\(usedString) of \(quotaUnit)"
        }

        return [
            TableRow(
                title: quotaString,
                progressData: ProgressCellData(
                    free: free,
                    total: total,
                    type: .storage)
            )
        ]
    }

    private func statusSection() -> [TableRow] {
        guard let userData = user?.data
        else { return emptyRows(for: StatusRow.self) }
        return StatusRow.allCases.map {
            TableRow(
                title: $0.title,
                secondaryText: $0.rowData(userData)
            )
        }
    }

    private func capabilitiesSection() -> [TableRow] {
        guard let capabilities = user?.data.backendCapabilities
        else { return emptyRows(for: Capabilities.self) }

        return Capabilities.allCases.map {
            capabilitiesRow(
                title: $0.title,
                isCapable: $0.rowData(capabilities)
            )
        }
    }

    private func capabilitiesRow(
        title: String, isCapable: Bool
    ) -> TableRow {
        if !isCapable {
            return TableRow(title: title, secondaryText: "No")
        }
        return TableRow(
            title: title, secondaryText: nil, accessoryType: .checkmark
        )
    }

    // MARK: - Helper Methods

    private func emptyRows<T: TitledSection>(for _: T.Type) -> [TableRow] {
        return T.allCases.map {
            TableRow(title: $0.title, secondaryText: "N/A")
        }
    }
}
