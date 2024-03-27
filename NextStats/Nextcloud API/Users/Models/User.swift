//
//  User.swift
//  User
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
    let storageLocation: String?
    let id: String
    let lastLogin: Int?
    let backend: String?
    let subadmin: SubAdmin?
    let quota: Quota
    let email: String?
    let additionalMail: AdditionalMail?
    let displayname: String?
    let phone: Int?
    let address: String?
    let website: String?
    let twitter: String?
    let groups: Groups?
    let language: String?
    let locale: String?
    let backendCapabilities: BackendCapabilities

    enum CodingKeys: String, CodingKey {
        case enabled
        case storageLocation
        case id
        case lastLogin
        case backend
        case subadmin
        case quota
        case email
        case additionalMail = "additional_mail"
        case displayname
        case phone
        case address
        case website
        case twitter
        case groups
        case language
        case locale
        case backendCapabilities
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.enabled = try container.decode(Bool.self, forKey: .enabled)
        self.storageLocation = try? container.decode(String.self, forKey: .storageLocation)
        self.id = try container.decode(String.self, forKey: .id)
        self.lastLogin = try? container.decode(Int.self, forKey: .lastLogin)
        self.backend = try? container.decode(String.self, forKey: .backend)
        self.subadmin = try? container.decode(SubAdmin.self, forKey: .subadmin)
        self.quota = try container.decode(Quota.self, forKey: .quota)
        self.email = try? container.decode(String.self, forKey: .email)
        self.additionalMail = try? container.decode(AdditionalMail.self, forKey: .additionalMail)
        self.displayname = try? container.decode(String.self, forKey: .displayname)
        self.phone = try? container.decode(Int.self, forKey: .phone)
        self.address = try? container.decode(String.self, forKey: .address)
        self.website = try? container.decode(String.self, forKey: .website)
        self.twitter = try? container.decode(String.self, forKey: .twitter)
        self.groups = try? container.decode(Groups.self, forKey: .groups)
        self.language = try? container.decode(String.self, forKey: .language)
        self.locale = try? container.decode(String.self, forKey: .locale)
        self.backendCapabilities = try container.decode(BackendCapabilities.self, forKey: .backendCapabilities)
    }
}

struct AdditionalMail: Codable {
    let element: ElementContainer?
}

struct Quota: Codable {
    let free: Int?
    let used: Int?
    let total: Int?
    let relative: Double?
    let quota: QuotaContainer?
}

enum QuotaContainer: Codable {
    case int(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let data = try? container.decode(Int.self) {
            self = .int(data)
            return
        }

        if let data = try? container.decode(String.self) {
            self = .string(data)
            return
        }

        throw DecodingError.typeMismatch(ElementContainer.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Group type mismatch"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let data):
            try container.encode(data)
        case .string(let data):
            try container.encode(data)
        }
    }
}

struct SubAdmin: Codable {
    let element: ElementContainer?
}

struct Groups: Codable {
    let element: ElementContainer?
}

enum ElementContainer: Codable {
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

        throw DecodingError.typeMismatch(ElementContainer.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Group type mismatch"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .stringArray(let data):
            try container.encode(data)
        case .string(let data):
            try container.encode(data)
        }
    }
}

struct BackendCapabilities: Codable {
    let setDisplayName: Bool?
    let setPassword: Bool?
}
