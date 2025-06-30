//
//  UserCellModel.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/15/23.
//  Copyright © 2023 Jon Alaniz. All rights reserved.
//

import Foundation

struct UserCellModel {
    let userID: String
    let displayName: String
    let email: String
    let enabled: Bool

    func toggled() -> UserCellModel {
        return UserCellModel(
            userID: self.userID,
            displayName: self.displayName,
            email: self.email,
            enabled: !self.enabled
        )
    }
}
