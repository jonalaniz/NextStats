//
//  AuthResponse.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

// Authorization Structs - Objects used in authorizaton flow
struct AuthResponse: Codable {
    let poll: Poll?
    let login: String?
}

struct Poll: Codable {
    let token: String?
    let endpoint: String?
}

struct ServerAuthenticationInfo: Codable {
    let server: String?
    let loginName: String?
    let appPassword: String?
}
