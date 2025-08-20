//
//  SFSymbol.swift
//  NextStats
//
//  Created by Jon Alaniz on 8/16/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

enum SFSymbol: String {
    case addServer = "externaldrive.fill.badge.plus"
    case cheveron = "chevron.right"
    case ellipsis = "ellipsis"
    case info = "info"
    case infoFilled = "info.circle.fill"
    case internalDrive = "internaldrive"
    case memorychip = "memorychip"
    case safari = "safari.fill"
    case swap = "memorychip.fill"
    case plus = "plus"
    case user = "person.fill"

    var image: UIImage? {
        return UIImage(systemName: self.rawValue)
    }
}
