//
//  ImageAsset.swift
//  NextStats
//
//  Created by Jon Alaniz on 9/11/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

enum ImageAsset {
    case appIcon
    case appIconClear
    case connectImage

    var image: UIImage? {
        UIImage(named: self.name)
    }

    private var name: String {
        switch self {
        case .appIcon: SystemVersion.isiOS26 ? "icon26" : "nextstat-logo"
        case .appIconClear: SystemVersion.isiOS26 ? "icon26-clear" : "Greyscale-Icon"
        case .connectImage: SystemVersion.isiOS26 ? "ios26-nextcloud-drive-connect" : "nextcloud-drive-connect"
        }
    }
}
