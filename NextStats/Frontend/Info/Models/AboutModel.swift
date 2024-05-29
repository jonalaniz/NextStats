//
//  AboutModel.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/17/20.
//  Copyright © 2020 Jon Alaniz.
//

import StoreKit
import UIKit

protocol AboutModelDelegate: AnyObject {
    func iapEnabled()
}

enum AboutSection: Int, CaseIterable {
    case icon, development, translators, licenses, support
}

class AboutModel: NSObject {
    public static let shared = AboutModel()
    weak var delegate: AboutModelDelegate?

    private var sections: [String] = ["App Icon",
                                      .localized(.infoScreenDevHeader),
                                      .localized(.infoScreenLocaleHeader),
                                      .localized(.infoScreenLicenseHeader)]
    private let developerTitles: [String] = [.localized(.infoScreenDevTitle)]

    private let developerNames = ["Jon Alaniz"]
    private let translatorLanguages: [String] = [.localized(.infoScreenLocaleFrench),
                                                 .localized(.infoScreenLocaleGerman),
                                                 .localized(.infoScreenLocaleTurkish)]
    private let translatorNames = ["Maxime Killinger",
                                   "Carina Pfaffelhuber",
                                   "Hüseyin Fahri Uzun"]
    private let licences = ["MIT License",
                            "GNU AGPLv3 License"]

    private var products = [SKProduct]()

    func toggleIcon() {
        let icon = UIApplication.shared.alternateIconName
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }

        guard icon != nil else {
            // Set the icon to `AppIcon-Light`
            UIApplication.shared.setAlternateIconName("AppIcon-Light")
            return
        }

        UIApplication.shared.setAlternateIconName(nil)
    }

    func licenseURLFor(row: Int) -> String {
        switch row {
        case 0:
            // NextStats MIT License URL
            return "https://github.com/jonalaniz/NextStats/blob/main/LICENSE"
        default:
            // Nextcloud License URL
            return "https://github.com/nextcloud/nextcloud.com/blob/master/LICENSE"
        }
    }

    func checkForProducts() {
        // Check if user can make payments
        guard IAPHelper.canMakePayments() else { return }

        // If products can be reached, insert the IAP Section into the TableView
        NextStatsProducts.store.requestProducts { [self] success, products in
            guard success else { return }
            guard let unwrappedProducts = products else { return }

            DispatchQueue.main.async {
                self.products = unwrappedProducts
                self.sections.append(.localized(.infoScreenSupportHeader))
                self.delegate?.iapEnabled()
            }
        }
    }

    func buyProduct(_ row: Int) {
        NextStatsProducts.store.buyProduct(products[row])
    }
}

extension AboutModel: UITableViewDataSource {
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
