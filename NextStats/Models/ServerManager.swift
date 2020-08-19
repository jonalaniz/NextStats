//
//  ServerManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/3/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation
import UIKit

let loginEndpoint = "/index.php/login/v2"
let logoEndpoint = "/index.php/apps/theming/image/logo"

@objc public protocol ServerManagerDelegate: class {
    /**
     Called when server is successfully added to the manager
     */
    @objc optional func serverAdded()
}

open class ServerManager {
    // Manages the creation, deletion, encoding, and decoding of server objects
    
    /// Returns the singleton ServerManager instance.
    public static let shared = ServerManager()
    
    /**
     The delegate object for the 'ServerManager'.
     */
    open weak var delegate: ServerManagerDelegate?
    
    var servers = [NextServer]() {
        didSet {
            // sort, then encode array into keychain
            KeychainWrapper.standard.set(try! PropertyListEncoder().encode(servers), forKey:"servers")
        }
    }
    
    init() {
        // try to pull server data from keychain
        if let data = KeychainWrapper.standard.data(forKey:"servers") {
            if let savedServers = try? PropertyListDecoder().decode([NextServer].self, from: data) {
                self.servers = savedServers
                return
            }
        }
        // if data is not available, create empty array
        self.servers = []
    }
    
    func addServer() {
        
        delegate?.serverAdded?()
    }
}




