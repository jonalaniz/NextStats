//
//  HeaderKeyValue.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

enum Header {
    case acceptJSON
    case authorization
    case contentType
    case maintenance
    case ocsAPIRequest
    case userAgent(String)

    // Method to get the string representation of the header key
    func key() -> String {
        switch self {
        case .acceptJSON: return "Accept"
        case .authorization: return "Authorization"
        case .contentType: return "Content-Type"
        case .maintenance: return "x-nextcloud-maintenance-mode"
        case .ocsAPIRequest: return "OCS-APIRequest"
        case .userAgent: return "User-Agent"
        }
    }

    // Method to get the string representation of the header value
    func value() -> String {
        switch self {
        case .acceptJSON: return "application/json"
        case .authorization: return "" // Don't call this one
        case .contentType: return "application/json"
        case .maintenance: return "1"
        case .ocsAPIRequest: return "true"
        case .userAgent(let string): return "NextStats for \(string)"
        }
    }
}
