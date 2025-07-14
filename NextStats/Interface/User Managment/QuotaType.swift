//
//  QuotaType.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/25/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

/// Represents storage quota options when creating a new Nextcloud user.
///
/// `QuotaType` defines common storage size presets and a default option. It provides both
/// a user-friendly display string and a server-compatible string used when submitting
/// data to the Nextcloud API.
enum QuotaType: CaseIterable {
    case defaultQuota
    case oneGB
    case fiveGB
    case tenGB

    init?(displayName: String) {
        switch displayName {
        case "Default": self = .defaultQuota
        case "1 GB": self = .oneGB
        case "5 GB": self = .fiveGB
        case "10 GB": self = .tenGB
        default: return nil
        }
    }

    /// A human-readable label for display in the UI (e.g., in dropdowns or labels).
    var displayName: String {
        switch self {
        case .defaultQuota: return "Default"
        case .oneGB: return "1 GB"
        case .fiveGB: return "5 GB"
        case .tenGB: return "10 GB"
        }
    }

    /// The string value expected by the Nextcloud server when setting a user quota.
    ///
    /// This value is sent during user creation. If `nil`, the default quota is applied.
    var serverValue: String? {
        switch self {
        case .defaultQuota: return nil
        case .oneGB: return "1073741824"
        case .fiveGB: return "5368709120"
        case .tenGB: return  "10737418240"
        }
    }
}
