//
//  UsersDelegate.swift
//  UsersDelegate
//
//  Created by Jon Alaniz on 7/24/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

protocol UsersDelegate: AnyObject {
    /// Called when users were successfully added
    func didRecieveUsers()
}
