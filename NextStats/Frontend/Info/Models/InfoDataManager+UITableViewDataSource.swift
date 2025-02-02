//
//  AboutModel+UITableViewDataSource.swift
//  NextStats
//
//  Created by Jon Alaniz on 5/29/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

extension InfoDataManager: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let tableSection = InfoSection(rawValue: section)
        else { return "" }

        switch tableSection {
        case .licenses: return .localized(.infoScreenLicenseDescription)
        case .support: return .localized(.infoScreenSupportDescription)
        default: return ""
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = InfoSection(rawValue: section)
        else { return 0 }

        switch tableSection {
        case .icon: return 1
        case .development: return developerNames.count
        case .translators: return translatorNames.count
        case .licenses: return licenses.count
        case .support: return products.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = InfoSection(rawValue: indexPath.section)
        else { return UITableViewCell() }

        let row = indexPath.row

        switch tableSection {
        case .icon: return iconCell(row)
        case .development: return developerCell(row)
        case .translators: return translationCell(row)
        case .licenses: return licensesCell(row)
        case .support: return productsCell(row)
        }
    }

    private func iconCell(_ row: Int) -> UITableViewCell {
        let light = UIApplication.shared.alternateIconName
        let secondaryText = (light != nil) ? ("Light") : ("Default")

        return infoTableViewCell(style: .value1,
                                 reuseIdentifier: "IconCell",
                                 text: "App Icon Type",
                                 secondaryText: secondaryText)
    }

    private func developerCell(_ row: Int) -> UITableViewCell {
        return infoTableViewCell(style: .value1,
                                 reuseIdentifier: "DeveloperCell",
                                 text: .localized(.infoScreenDevTitle),
                                 secondaryText: developerNames[row],
                                 isInteractive: false)
    }

    private func translationCell(_ row: Int) -> UITableViewCell {
        return infoTableViewCell(style: .value1,
                                 reuseIdentifier: "TranslationCell",
                                 text: translatorLanguages[row],
                                 secondaryText: translatorNames[row],
                                 isInteractive: false)
    }

    private func licensesCell(_ row: Int) -> UITableViewCell {
        return infoTableViewCell(style: .default,
                                 reuseIdentifier: "LicenseCell",
                                 text: licenses[row],
                                 accessoryType: .disclosureIndicator)
    }

    private func productsCell(_ row: Int) -> UITableViewCell {
        let product = products[row]

        // Setup currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale

        let cost = formatter.string(from: product.price)

        return infoTableViewCell(style: .value1,
                                 reuseIdentifier: "SupportCell",
                                 text: product.localizedTitle,
                                 secondaryText: cost)
    }

    private func infoTableViewCell(style: UITableViewCell.CellStyle,
                                   reuseIdentifier: String,
                                   text: String,
                                   secondaryText: String? = nil,
                                   isInteractive: Bool = true,
                                   accessoryType: UITableViewCell.AccessoryType = .none) -> UITableViewCell {
        let cell = UITableViewCell(style: style, reuseIdentifier: reuseIdentifier)
        cell.isUserInteractionEnabled = isInteractive
        cell.accessoryType = accessoryType

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .theme
        content.secondaryTextProperties.color = .secondaryLabel
        content.text = text
        content.secondaryText = secondaryText
        cell.contentConfiguration = content

        return cell
    }
}
