//
//  UserCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/15/23.
//  Copyright © 2023 Jon Alaniz. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    var user: UserCellModel!

    func setup() {
        textLabel?.text = "\(user.displayName) (\(user.userID))"
        detailTextLabel?.text = enabled()

        user.enabled ? (detailTextLabel?.textColor = .themeColor) : (detailTextLabel?.textColor = .secondaryLabel)
    }

    func enabled() -> String {
        return user.enabled ? "enabled" : "disabled"
    }
}
