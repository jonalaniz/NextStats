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
}

enum NXUserManagerState {
    case deletedUser
    case toggledUser
    case usersLoaded
}
