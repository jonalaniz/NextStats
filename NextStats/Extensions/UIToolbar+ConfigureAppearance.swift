//
//  UIToolbar+ConfigureAppearance.swift
//  UIToolbar+ConfigureAppearance
//
//  Created by Jon Alaniz on 7/15/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import UIKit

extension UIToolbar {
    /// Configures toolbar to have black background for iOS platforms
    func configureAppearance() {
        #if !targetEnvironment(macCatalyst)

        let appearance = UIToolbarAppearance()

        if #available(iOS 15.0, *) {
            appearance.configureWithOpaqueBackground()
            self.standardAppearance = appearance
            self.scrollEdgeAppearance = appearance
        }

        self.isTranslucent = false
        self.barTintColor = .systemGroupedBackground
        self.setShadowImage(UIImage(), forToolbarPosition: .bottom)

        #endif
    }
}
