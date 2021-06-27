//
//  AboutModel.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/17/20.
//  Copyright © 2020 Jon Alaniz
//

import Foundation

// MARK: - InfoModel
/**
    InfoModel contains infomration pertaining to the development of NextStats.
 */
struct InfoModel {
    private let sections = ["Development".localized(), "Translators".localized(), "Licenses".localized()]
    private let developerTitles = ["Developer".localized()]
    private let developerNames = ["Jon Alaniz"]
    private let translatorLanguages = ["French".localized(), "German".localized()]
    private let translatorNames = ["Maxime Killinger", "Carina Pfaffelhuber"]
    private let licences = ["MIT License", "GNU AGPLv3 License"]

    func numberOfSections() -> Int {
        return sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        switch section {
        case 0: return developerNames.count
        case 1: return translatorNames.count
        case 2: return licences.count
        default: return 0
        }
    }

    func title(for section: Int) -> String {
        return sections[section]
    }

    func footer(for section: Int) -> String {
        switch section {
        case 2:
            return "NextStats is provided under the MIT License. Nextcloud itself is provided by Nextcloud GmbH under the AGPLv3 License".localized()
        case 3:
            return "NextStats is and will always be free. If you find the app usefull, please considering leaving a tip to help further its development.".localized()
        default:
            return ""
        }
    }

    func titleLabelFor(row: Int, section: Int) -> String {
        switch section {
        case 0: return developerTitles[row]
        case 1: return translatorLanguages[row]
        case 2: return licences[row]
        default: return ""
        }
    }

    func detailLabelFor(row: Int, section: Int) -> String? {
        switch section {
        case 0: return developerNames[row]
        case 1: return translatorNames[row]
        default: return ""
        }
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
}
