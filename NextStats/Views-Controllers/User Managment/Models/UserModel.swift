//
//  UserModel.swift
//  UserModel
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

// swiftlint:disable identifier_name
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
    let element: GroupElement
}

enum GroupElement: Codable {
    case string(String)
    case stringArray([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let data = try? container.decode(String.self) {
            self = .string(data)
            return
        }

        if let data = try? container.decode([String].self) {
            self = .stringArray(data)
            return
        }

        throw DecodingError.typeMismatch(Groups.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Group type mismatch"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .stringArray(let data):
            try container.encode(data)
        case.string(let data):
            try container.encode(data)
        }
    }
}

struct BackendCapabilities: Codable {
    let setDisplayName: Bool?
    let setPassword: Bool?
}
