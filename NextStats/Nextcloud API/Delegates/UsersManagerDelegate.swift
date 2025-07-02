//
//  UsersManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/30/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

protocol UsersManagerDelegate: AnyObject {
    func userDeleted(_ user: UserCellModel)
    func usersLoaded(_ users: [UserCellModel])
    func toggledUser(with id: String)
}
