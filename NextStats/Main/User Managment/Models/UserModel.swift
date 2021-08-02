//
//  UserModel.swift
//  UserModel
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

struct User: Codable {
    let meta: Meta
    let data: UserDataStruct
}

struct UserDataStruct: Codable {
    let enabled: Bool
    let storageLocation: String
    let id: String
    let lastLogin: Int?
    let backend: String?
    let subadmin: String?
    let quota: Quota
    let email: String?
    let additionalMail: String?
    let displayname: String?
    let phone: Int?
    let address: String?
    let website: String?
    let twitter: String?
    let groups: Groups?
    let language: String?
    let locale: String?
    let backendCapabilities: BackendCapabilities
}

struct Quota: Codable {
    let free: Int?
    let used: Int?
    let total: Int?
    let relative: Double? // Double
    let quota: String?
}

struct Groups: Codable {
    let element: String?
}

struct BackendCapabilities: Codable {
    let setDisplayName: Bool?
    let setPassword: Bool?
}
