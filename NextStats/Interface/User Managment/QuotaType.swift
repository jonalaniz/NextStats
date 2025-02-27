//
//  QuotaType.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/25/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

enum QuotaType: String, CaseIterable {
    case defaultQuota = "Default"
    case oneGB = "1 GB"
    case fiveGB = "5 GB"
    case tenGB = "10 GB"

    var string: String? {
        switch self {
        case .defaultQuota: return nil
        case .oneGB: return "1073741824"
        case .fiveGB: return "5368709120"
        case .tenGB: return  "10737418240"
        }
    }
}
