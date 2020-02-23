//
//  Extensions.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/15/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

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

extension UINavigationController {

    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = UIColor(displayP3Red: 22, green: 24, blue: 39, alpha: 1)
        view.addSubview(statusBarView)
    }

}
