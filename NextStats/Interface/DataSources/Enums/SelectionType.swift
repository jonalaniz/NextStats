//
//  SelectionType.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/23/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum SelectionType {
    case groups, subAdmin, quota

    var title: String {
        switch self {
        case .groups: return .localized(.groups)
        case .subAdmin: return .localized(.adminOf)
        case .quota: return .localized(.quota)
        }
    }
}
