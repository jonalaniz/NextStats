//
//  Extensions.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/15/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

extension String {
    /// Adds https:// prefix for use with a URL string
    func addDomainPrefix() -> String {
        if self.hasPrefix("http://") {
            return "https://" + self
        } else if self.hasPrefix("https://") {
            return self
        } else {
            return "https://" + self
        }
    }

    /// Adds http:// prefix for use with an IP address string
    func addIPPrefix() -> String {
        if self.hasPrefix("http://") {
            return self
        } else {
            return "http://" + self
        }
    }

    /// Check's url for HTTP prefix, adds one if not present
    func addHTTPPrefix() -> String {
        if self.hasPrefix("http://") || self.hasPrefix("https://") {
            return self
        } else {
            return "https://" + self
        }
    }

    /// Returns the String as an NSAttributedString with foreground color of QuaternaryLabel
    func attributedWithQuaternaryColor() -> NSAttributedString {
        return NSAttributedString(string: self,
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.quaternaryLabel])
    }

    /// Returns wether the string is an IP address
    func isValidIPAddress() -> Bool {
        var testableString = self
        if let index = testableString.range(of: ":") {
          testableString.removeSubrange(index.lowerBound..<testableString.endIndex)
        }

        let parts = testableString.components(separatedBy: ".")
        let nums = parts.compactMap { Int($0) }
        return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256 }.count == 4
    }

    /// Removes https:// from a URL string 
    func makeFriendlyURL() -> String {
        if self.hasPrefix("https://") {
            return self.replacingOccurrences(of: "https://", with: "")
        } else {
            return self.replacingOccurrences(of: "http://", with: "")
        }
    }
}
