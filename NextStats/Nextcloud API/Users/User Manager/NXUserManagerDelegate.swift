//
//  NXUserManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/30/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

protocol NXUserManagerDelegate: AnyObject {
    func stateDidChange(_ state: NXUserManagerState)
    func error(_ error: NXUserManagerErrorType)
}

enum NXUserManagerState {
    case deletedUser
    case toggledUser
    case usersLoaded
}

enum NXUserManagerErrorType {
    case app(_ error: NXUserManagerError)
    case networking(NetworkError)
    case server(code: Int, status: String, message: String)
}

enum NXUserManagerError {
    case usersEmpty
}
