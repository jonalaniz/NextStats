//
//  UIToolbar+ConfigureAppearance.swift
//  UIToolbar+ConfigureAppearance
//
//  Created by Jon Alaniz on 7/15/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

extension UIToolbar {
    /// Configures toolbar to have black background
    func configureAppearance() {
        let appearance = UIToolbarAppearance()

        if #available(iOS 15.0, *) {
            appearance.configureWithOpaqueBackground()
            self.standardAppearance = appearance
            self.scrollEdgeAppearance = appearance
        }

        self.isTranslucent = false
        self.barTintColor = .systemGroupedBackground
        self.setShadowImage(UIImage(), forToolbarPosition: .bottom)
    }
}
