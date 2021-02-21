//
//  UIActivityIndicatorView+Activate:Deactivate.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/21/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {
    /// Unhides and starts animating Indicator View
    func activate() {
        self.isHidden = false
        self.startAnimating()
    }
    
    /// Hides and stops animating Indicator View
    func deactivate() {
        self.isHidden = true
        self.stopAnimating()
    }
}
