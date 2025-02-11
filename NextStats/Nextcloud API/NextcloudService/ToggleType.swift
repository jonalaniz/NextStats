//
//  ToggleType.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/19/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

enum ToggleType {
    case enable
    case disable
    case delete

    var httpMethod: ServiceMethod {
        switch self {
        case .enable: return .put
        case .disable: return .put
        case .delete: return .delete
        }
    }

    func path(for user: String) -> String {
        switch self {
        case .enable: return "\(user)/enable"
        case .disable: return "\(user)/disable"
        case .delete: return ""
        }
    }
}
