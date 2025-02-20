//
//  AboutModel.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/17/20.
//  Copyright © 2020 Jon Alaniz.
//

import StoreKit
import UIKit

class InfoDataManager: BaseDataManager {
    public static let shared = InfoDataManager()

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    var products = [SKProduct]()

    private init() {}

    @MainActor func toggleIcon() {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        let isLight = UIApplication.shared.alternateIconName != nil

        UIApplication.shared.setAlternateIconName(isLight ? nil : "AppIcon-Light")
        notifyDelegate(.dataUpdated)
    }

    func checkForProducts() {
        // Check if user can make payments
        guard IAPHelper.canMakePayments() else { return }

        // Check for products and notify delegate if successful
        NextStatsProducts.store.requestProducts { [self] success, products in
            guard
                success,
                let unwrappedProducts = products
            else { return }

            self.products = unwrappedProducts
            Task { await self.notifyDelegate(.dataUpdated) }
        }
    }

    func buyProduct(_ row: Int) {
        NextStatsProducts.store.buyProduct(products[row])
    }
}

extension InfoDataManager: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return products.isEmpty ? InfoSection.allCases.count - 1 : InfoSection.allCases.count
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
        guard let tableSection = InfoSection(rawValue: section)
        else { return 0 }

        return tableSection == .support ? products.count : tableSection.rows
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
        let isLight = UIApplication.shared.alternateIconName != nil
        return BaseTableViewCell(style: .value1,
                                 text: Icon.iconType.title,
                                 textColor: .theme,
                                 secondaryText: Icon.iconType.detail(isLight))
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
        return BaseTableViewCell(style: .value1,
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
