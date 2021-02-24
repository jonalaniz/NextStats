//
//  Notifications.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/21/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let serverDidChange = Notification.Name("serversDidChange")
    static let authenticationCanceled = Notification.Name("authenticationCanceled")
}
