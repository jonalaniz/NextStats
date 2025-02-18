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
        guard UIApplication.shared.supportsAlternateIcons else { return }

        let lightIconIsSet = UIApplication.shared.alternateIconName != nil
        UIApplication.shared.setAlternateIconName(lightIconIsSet ? nil : "AppIcon-Light")

        delegate?.dataUpdated()
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

        return BaseTableViewCell(style: .value1,
                                 text: "App Icon Type",
                                 textColor: .theme,
                                 secondaryText: secondaryText)
    }

    private func developerCell(_ row: Int) -> UITableViewCell {
        guard let developer = Developer(rawValue: row)
        else { return UITableViewCell() }
        return BaseTableViewCell(style: .value1,
                                 text: developer.title,
                                 secondaryText: developer.name,
                                 isInteractive: false)
    }

    private func translationCell(_ row: Int) -> UITableViewCell {
        guard let translator = Translator(rawValue: row)
        else { return UITableViewCell() }
        return BaseTableViewCell(style: .value1,
                                 text: translator.language,
                                 secondaryText: translator.name,
                                 isInteractive: false)
    }

    private func licensesCell(_ row: Int) -> UITableViewCell {
        guard let license = License(rawValue: row)
        else { return UITableViewCell() }
        return BaseTableViewCell(style: .default,
                                 text: license.title,
                                 accessoryType: .disclosureIndicator)
    }

    private func productsCell(_ row: Int) -> UITableViewCell {
        let product = products[row]
        formatter.locale = product.priceLocale
        let cost = formatter.string(from: product.price)

        return BaseTableViewCell(style: .value1,
                                 text: product.localizedTitle,
                                 secondaryText: cost)
    }
}
