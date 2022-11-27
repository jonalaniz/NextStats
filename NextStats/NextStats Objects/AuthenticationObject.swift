//
//  AuthenticationObject.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

// Authorization Structs - Objects used in authorizaton flow
struct AuthenticationObject: Decodable {
    let poll: Poll?
    let login: String?
}

struct Poll: Codable {
    let token: String?
    let endpoint: String?
}
