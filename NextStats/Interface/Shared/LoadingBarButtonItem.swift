//
//  LoadingBarButtonItem.swift
//  NextStats
//
//  Created by Jon Alaniz on 9/6/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

final class LoadingBarButtonItem: UIBarButtonItem {
    private let indicator  = UIActivityIndicatorView(style: .medium)
    override init() {
        super.init()
        indicator.startAnimating()
        customView = indicator
        isEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("LoadingBarButtonItem cannot be initialized from storyboard")
    }
}
