//
//  Extensions.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/15/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit
import WebKit

extension String {
    // Replace http:// with https://
    func secureURLString() -> String {
        if self.hasPrefix("http://") {
            return self.replacingOccurrences(of: "http://", with: "https://")
        } else if self.hasPrefix("https://") {
            return self
        } else {
            return "https://" + self
        }
    }
    
    // Remove https://
    func makeFriendlyURL() -> String {
        return self.replacingOccurrences(of: "https://", with: "")
    }
}

extension UIActivityIndicatorView {
    func activate() {
        self.isHidden = false
        self.startAnimating()
    }
    
    func deactivate() {
        self.isHidden = true
        self.stopAnimating()
    }
    
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension WKWebView {
    func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Cookie ::: \(record) deleted")
            }
        }
    }

    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
    }
}
