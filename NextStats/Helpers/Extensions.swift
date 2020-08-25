//
//  Extensions.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/15/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit
import WebKit

extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}

extension Notification.Name {
    static let serverDidChange = Notification.Name("serversDidChange")
    static let authenticationCanceled = Notification.Name("authenticationCanceled")
}

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
    
    // Remove https://
    func makeFriendlyURL() -> String {
        if self.hasPrefix("https://") {
            return self.replacingOccurrences(of: "https://", with: "")
        } else {
            return self.replacingOccurrences(of: "http://", with: "")
        }
        
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
