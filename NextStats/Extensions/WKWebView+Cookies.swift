//
//  WKWebView+Cookies.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/21/21.
//  Copyright © 2021 Jon Alaniz
//

import WebKit

extension WKWebView {
    func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
    }
}
