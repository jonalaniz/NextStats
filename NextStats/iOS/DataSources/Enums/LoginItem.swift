//
//  LoginFields.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum LoginItem: Int, CaseIterable {
    case name = 0
    case url

    var placeholder: String {
        switch self {
        case .name: .localized(.addScreenNickname)
        case .url: .localized(.addScreenUrl)
        }
    }

    var tag: Int {
        switch self {
        case .name: return 10
        case .url: return 20
        }
    }

    var type: TextFieldType {
        switch self {
        case .name: return .normal
        case .url: return .URL
        }
    }

    init?(from tag: Int) {
        switch tag {
        case 10: self = .name
        case 20: self = .url
        default: return nil
        }
    }
}
