//
//  GenericResponse.swift
//  NextStats
//
//  Created by Jon Alaniz on 11/19/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

/// Generic Nextcloud Response Object for decoding `Meta` objects
struct GenericResponse: Codable {
    let meta: Meta
}

struct Meta: Codable {
    let status: String
    let statuscode: Int
    let message: String?
}
