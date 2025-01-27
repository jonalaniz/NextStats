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
        guard let tableSection = AboutSection(rawValue: section)
        else { return "" }

        switch tableSection {
        case .licenses: return .localized(.infoScreenLicenseDescription)
        case .support: return .localized(.infoScreenSupportDescription)
        default: return ""
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let tableSection = AboutSection(rawValue: section)
        else { return 0 }

        switch tableSection {
        case .icon: return 1
        case .development: return developerNames.count
        case .translators: return translatorNames.count
        case .licenses: return licences.count
        case .support: return products.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = AboutSection(rawValue: indexPath.section)
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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "IconCell")

        let light = UIApplication.shared.alternateIconName

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .themeColor
        content.secondaryTextProperties.color = .secondaryLabel
        content.text = "App Icon Type"

        (light != nil) ? (content.secondaryText = "Light") : (content.secondaryText = "Default")
        cell.contentConfiguration = content

        return cell
    }

    private func developerCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "DeveloperCell")
        cell.isUserInteractionEnabled = false

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .themeColor
        content.secondaryTextProperties.color = .secondaryLabel
        content.text = .localized(.infoScreenDevTitle)
        content.secondaryText = developerNames[row]
        cell.contentConfiguration = content

        return cell
    }

    private func translationCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "TranslationCell")
        cell.isUserInteractionEnabled = false

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .themeColor
        content.secondaryTextProperties.color = .secondaryLabel
        content.text = translatorLanguages[row]
        content.secondaryText = translatorNames[row]
        cell.contentConfiguration = content

        return cell
    }

    private func licensesCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "LicenseCell")
        cell.accessoryType = .disclosureIndicator

        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .themeColor
        content.text = licences[row]
        cell.contentConfiguration = content

        return cell
    }

    private func productsCell(_ row: Int) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "SupportCell")
        let product = products[row]

        // Setup currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale

        let cost = formatter.string(from: product.price)

        // Setup content
        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .themeColor
        content.text = product.localizedTitle
        content.secondaryText = cost
        cell.contentConfiguration = content

        return cell
    }
}
