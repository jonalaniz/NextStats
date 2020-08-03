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

class NextServers {
    var instances = [NextServer]() {
        didSet {
            // sort, then encode array into keychain
            KeychainWrapper.standard.set(try! PropertyListEncoder().encode(instances), forKey:"servers")
        }
    }
    
    init() {
        // try to pull server data from keychain
        if let data = KeychainWrapper.standard.data(forKey:"servers") {
            if let savedServers = try? PropertyListDecoder().decode([NextServer].self, from: data) {
                self.instances = savedServers
                return
            }
        }
        // if data is not available, create empty array
        self.instances = []
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
