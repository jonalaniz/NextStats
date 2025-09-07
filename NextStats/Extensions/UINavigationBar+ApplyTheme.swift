//
//  UINavigationBar+ApplyTheme.swift
//  NextStats
//
//  Created by Jon Alaniz on 9/6/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func applyTheme() {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.theme
        ]
        titleTextAttributes = attributes
        largeTitleTextAttributes = attributes
    }

    func setColor(_ color: UIColor) {
        let attributes = [
            NSAttributedString.Key.foregroundColor: color
        ]
        titleTextAttributes = attributes
        largeTitleTextAttributes = attributes
    }
}
