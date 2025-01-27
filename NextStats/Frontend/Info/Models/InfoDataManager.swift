//
//  AboutModel.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/17/20.
//  Copyright © 2020 Jon Alaniz.
//

import StoreKit
import UIKit

enum AboutSection: Int, CaseIterable {
    case icon, development, translators, licenses, support
}

class InfoDataManager: NSObject {
    public static let shared = InfoDataManager()
    weak var delegate: AboutModelDelegate?

    var sections: [String] = ["App Icon",
                              .localized(.infoScreenDevHeader),
                              .localized(.infoScreenLocaleHeader),
                              .localized(.infoScreenLicenseHeader)]
    let developerTitles: [String] = [.localized(.infoScreenDevTitle)]

    let developerNames = ["Jon Alaniz"]
    let translatorLanguages: [String] = [.localized(.infoScreenLocaleFrench),
                                         .localized(.infoScreenLocaleGerman),
                                         .localized(.infoScreenLocaleGerman),
                                         .localized(.infoScreenLocaleTurkish)]
    let translatorNames = ["Maxime Killinger",
                           "Carina Pfaffelhuber",
                           "@rakekniven",
                           "Hüseyin Fahri Uzun"]
    let licences = ["MIT License",
                    "GNU AGPLv3 License"]

    var products = [SKProduct]()

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
