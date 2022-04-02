//
//  UIApplication+AppVersion.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/21/21.
//  Copyright © 2021 Jon Alaniz.

import UIKit

extension UIApplication {
    /// Returns `CFBundleShortVersionString`
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
