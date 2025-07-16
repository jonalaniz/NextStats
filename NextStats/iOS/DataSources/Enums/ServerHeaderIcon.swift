//
//  ServerHeaderIcon.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/24/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

enum ServerHeaderIcon {
    case chevron
    case safari
    case user

    var image: UIImage? {
        switch self {
        case .chevron: return UIImage(systemName: "chevron.right")
        case .safari: return UIImage(systemName: "safari.fill")
        case .user: return UIImage(systemName: "person.fill")
        }
    }
}
