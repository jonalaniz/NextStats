//
//  UIView+BlurView.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/13/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

extension UIView {
    var blurView: UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.clipsToBounds = true
        effectView.backgroundColor = .clear

        return effectView
    }

    func addGlow(opacity: Float = 0.2) {
        layer.shadowColor = UIColor.theme.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 40
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
}
