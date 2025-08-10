//
//  SystemVersion.swift
//  NextStats
//
//  Created by Jon Alaniz on 7/29/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

enum SystemVersion {
    static var isiOS26: Bool {
        if #available(iOS 26, *) { return true }
        return false
    }
}
