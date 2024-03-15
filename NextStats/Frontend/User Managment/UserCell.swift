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
        var content = defaultContentConfiguration()

        content.text = "\(user.displayName) (\(user.userID))"
        content.secondaryText = enabled()

        let color: UIColor
        user.enabled ? (color = .themeColor) : (color = .secondaryLabel)
        content.secondaryTextProperties.color = color

        contentConfiguration = content
    }

    func enabled() -> String {
        return user.enabled ? .localized(.enabled) : .localized(.disabled)
    }
}
