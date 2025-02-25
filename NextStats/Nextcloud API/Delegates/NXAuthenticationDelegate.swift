//
//  NXAuthenticationDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

/// Functions called by ServerManager pertaining to authenitcation status
protocol NXAuthenticationDelegate: AnyObject {
    /// Called when server is successfully added to the manager
    func didCapture(server: NextServer)

    /// Called when login url and associated authorization data is recieved.
    func didRecieve(loginURL: String)
}
