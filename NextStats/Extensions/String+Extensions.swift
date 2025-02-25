//
//  Extensions.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/15/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

extension String {
    /// Adds http:// prefix for use with an IP address string
    mutating func addIPPrefix() {
        self.hasPrefix("http://") ? (nil) : (self = "http://" + self)
    }

    /// Check's url for HTTP prefix, adds one if not present
    mutating func addHTTPPrefix() {
        self.hasPrefix("http://") || self.hasPrefix("https://") ? (nil) : (self = "https://" + self)
    }

    /// Returns wether the string is an IP address
    func isValidIPAddress() -> Bool {
        let testableString = self.components(separatedBy: ":").first ?? self
        let parts = testableString.components(separatedBy: ".")
        let nums = parts.compactMap { Int($0) }
        return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256 }.count == 4
    }
}
