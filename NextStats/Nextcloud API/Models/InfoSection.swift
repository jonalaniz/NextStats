//
//  InfoSection.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/11/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum InfoSection: Int, CaseIterable {
    case icon, development, translators, licenses, support

    var title: String {
        switch self {
        case .icon: return "App Icon"
        case .development: return .localized(.infoScreenDevHeader)
        case .translators: return .localized(.infoScreenLocaleHeader)
        case .licenses: return .localized(.infoScreenLicenseHeader)
        case .support: return .localized(.infoScreenSupportHeader)
        }
    }

    var footer: String? {
        switch self {
        case .licenses: return .localized(.infoScreenLicenseDescription)
        case .support: return .localized(.infoScreenSupportDescription)
        default: return nil
        }
    }
}

enum Developer: Int, CaseIterable {
    case jon

    var title: String {
        switch self {
        case .jon: return .localized(.infoScreenDevTitle)
        }
    }

    var name: String {
        switch self {
        case .jon: return "Jon Alaniz"
        }
    }
}

enum Translator: Int, CaseIterable {
    case maxime, carina, rakekniven, huseyin

    var name: String {
        switch self {
        case .maxime: return "Maxime Killinger"
        case .carina: return "Carina Pfaffelhuber"
        case .rakekniven: return "@rakekniven"
        case .huseyin: return "Hüseyin Fahri Uzun"
        }
    }

    var language: String {
        switch self {
        case .maxime: return .localized(.infoScreenLocaleFrench)
        case .carina: return .localized(.infoScreenLocaleGerman)
        case .rakekniven: return .localized(.infoScreenLocaleGerman)
        case .huseyin: return .localized(.infoScreenLocaleTurkish)
        }
    }
}

enum License: Int, CaseIterable {
    case mit, gnu

    var title: String {
        switch self {
        case .mit: return "MIT License"
        case .gnu: return "GNU AGPLv3 License"
        }
    }

    var urlString: String {
        switch self {
        case .mit:
            return "https://github.com/jonalaniz/NextStats/blob/main/LICENSE"
        case .gnu:
            return "https://github.com/nextcloud/nextcloud.com/blob/master/LICENSE"
        }
    }
}
