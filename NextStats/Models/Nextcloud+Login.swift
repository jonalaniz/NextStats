//
//  Nextcloud+Login.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/3/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation
import UIKit

let loginEndpoint = "/index.php/login/v2"
let logoEndpoint = "/index.php/apps/theming/image/logo"

// ----------------------------------------------------------------------------
// MARK: - Server Address + Login Struct
// ----------------------------------------------------------------------------

struct NextServer: Codable {
    let name: String
    let friendlyURL: String
    let URLString: String
    let username: String
    let password: String
    let hasCustomLogo: Bool
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func imageURL() -> URL {
        let url = URL(string: URLString)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = ""
        
        return (components.url?.appendingPathComponent(logoEndpoint))!
    }
    
    func imagePath() -> String {
        return documentsDirectory.appendingPathComponent("\(friendlyURL).png", isDirectory: true).path
    }
    
    func imageCached() -> Bool {
        let path = imagePath()
        if FileManager.default.fileExists(atPath: path) {
            print(FileManager.default.fileExists(atPath: path))
            return true
        } else {
            print(FileManager.default.fileExists(atPath: path))
            return false
        }
    }
    
    func cachedImage() -> UIImage {
        return UIImage(contentsOfFile: imagePath())!
    }
}

// ----------------------------------------------------------------------------
// MARK: - Authorization Structs - For use when adding server
// ----------------------------------------------------------------------------
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
