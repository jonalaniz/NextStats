//
//  Extensions.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/15/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

extension String {
    // Add https
    func addDomainPrefix() -> String {
        if self.hasPrefix("http://") {
            return "https://" + self
        } else if self.hasPrefix("https://") {
            return self
        } else {
            return "https://" + self
        }
    }
    
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
            return "http://" + self
        }
    }
    
    // Remove https://
    func makeFriendlyURL() -> String {
        if self.hasPrefix("https://") {
            return self.replacingOccurrences(of: "https://", with: "")
        } else {
            return self.replacingOccurrences(of: "http://", with: "")
        }
    }
}


