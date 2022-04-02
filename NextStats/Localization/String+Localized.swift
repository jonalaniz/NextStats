//
//  String+Localized.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/21/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

extension String {
    /// Returns NSLocalizedString for given String
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    static func localized(_ key: LocalizedKeys) -> String {
        return key.rawValue.localized
    }
}
