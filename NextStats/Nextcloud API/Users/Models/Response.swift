//
//  Response.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/26/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

struct Response: Codable {
    let meta: NewUserResponse
}

struct NewUserResponse: Codable {
    let status: String
    let statuscode: Int
    let message: String
}
