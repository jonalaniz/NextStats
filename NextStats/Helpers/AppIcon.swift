//
//  AppIcon.swift
//  NextStats
//
//  Created by Jon Alaniz on 9/11/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

enum AppIcon {
    case clear
    case normal

    var image: UIImage? {
        UIImage(named: self.name)
    }

    private var name: String {
        switch self {
        case .clear: SystemVersion.isiOS26 ? "icon26-clear" : "Greyscale-Icon"
        case .normal: SystemVersion.isiOS26 ? "icon26" : "nextstat-logo"
        }
    }
}
