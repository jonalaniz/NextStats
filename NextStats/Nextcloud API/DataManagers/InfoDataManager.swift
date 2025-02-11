//
//  AboutModel.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/17/20.
//  Copyright © 2020 Jon Alaniz.
//

import StoreKit
import UIKit

class InfoDataManager: NSObject {
    public static let shared = InfoDataManager()
    weak var delegate: DataManagerDelegate?

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    var products = [SKProduct]()

    private override init() {}

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

    func checkForProducts() {
        // Check if user can make payments
        guard IAPHelper.canMakePayments() else { return }

        // If products can be reached, insert the IAP Section into the TableView
        NextStatsProducts.store.requestProducts { [self] success, products in
            guard success else { return }
            guard let unwrappedProducts = products else { return }

            DispatchQueue.main.async {
                self.products = unwrappedProducts
                self.delegate?.dataUpdated()
            }
        }
    }

    func buyProduct(_ row: Int) {
        NextStatsProducts.store.buyProduct(products[row])
    }
}

extension InfoDataManager: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard !products.isEmpty else { return InfoSection.allCases.count - 1 }
        return InfoSection.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return InfoSection(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView,
                   titleForFooterInSection section: Int) -> String? {
        return InfoSection(rawValue: section)?.footer
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch InfoSection(rawValue: section) {
        case .icon: return 1
        case .development: return Developer.allCases.count
        case .translators: return Translator.allCases.count
        case .licenses: return License.allCases.count
        case .support: return products.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableSection = InfoSection(rawValue: indexPath.section)
        else { return UITableViewCell() }

        let row = indexPath.row

        switch tableSection {
        case .icon: return iconCell()
        case .development: return developerCell(row)
        case .translators: return translationCell(row)
        case .licenses: return licensesCell(row)
        case .support: return productsCell(row)
        }
    }

    private func iconCell() -> UITableViewCell {
        let light = UIApplication.shared.alternateIconName
        let secondaryText = (light != nil) ? ("Light") : ("Default")

        return configureCell(style: .value1,
                             reuseIdentifier: "IconCell",
                             text: "App Icon Type",
                             secondaryText: secondaryText)
    }

    private func developerCell(_ row: Int) -> UITableViewCell {
        guard let developer = Developer(rawValue: row)
        else { return UITableViewCell() }
        return configureCell(style: .value1,
                             reuseIdentifier: "DeveloperCell",
                             text: developer.title,
                             secondaryText: developer.name,
                             isInteractive: false)
    }

    private func translationCell(_ row: Int) -> UITableViewCell {
        guard let translator = Translator(rawValue: row)
        else { return UITableViewCell() }
        return configureCell(style: .value1,
                             reuseIdentifier: "TranslationCell",
                             text: translator.language,
                             secondaryText: translator.name,
                             isInteractive: false)
    }

    private func licensesCell(_ row: Int) -> UITableViewCell {
        guard let license = License(rawValue: row)
        else { return UITableViewCell() }
        return configureCell(style: .default,
                             reuseIdentifier: "LicenseCell",
                             text: license.title,
                             accessoryType: .disclosureIndicator)
    }

    private func productsCell(_ row: Int) -> UITableViewCell {
        let product = products[row]
        formatter.locale = product.priceLocale
        let cost = formatter.string(from: product.price)

        return configureCell(style: .value1,
                             reuseIdentifier: "SupportCell",
                             text: product.localizedTitle,
                             secondaryText: cost)
    }

    private func configureCell(style: UITableViewCell.CellStyle,
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
