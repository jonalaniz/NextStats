//
//  NewUser.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/14/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

struct NewUser: Codable {
    let userid: String
    let password: String?
    let displayName: String?
    let email: String?
    let groups: [String]?
    let subAdmin: [String]?
    let quota: String?
    let language: String?
}
