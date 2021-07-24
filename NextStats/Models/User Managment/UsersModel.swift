//
//  UsersModel.swift
//  UsersModel
//
//  Created by Jon Alaniz on 7/24/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import Foundation

struct Users: Codable {
    let meta: Meta
    let data: UsersDataStruct
}

struct UsersDataStruct: Codable {
    let users: UsersStruct
}

struct UsersStruct: Codable {
    let element: [String]
}
