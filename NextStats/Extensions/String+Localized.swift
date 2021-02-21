//
//  String+Localized.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/21/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

extension String {
    /// Returns NSLocalizedString for given String
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
