//
//  UserCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/15/23.
//  Copyright © 2023 Jon Alaniz. All rights reserved.
//

import UIKit

/// A table view cell that displays user information.
///
/// `UserCell` is responsible for displaying a user's display name, user ID, and their enabled/disabled status.
/// It uses `defaultContentConfiguration()` to set up its appearance and supports single-line text truncation
/// to prevent wrapping.
class UserCell: BaseTableViewCell {
    static let reuseIdentifier = "UserCell"

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?) {
        super.init(
            style: .subtitle,
            reuseIdentifier: UserCell.reuseIdentifier
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with user: UserCellModel) {
        var config = defaultContentConfiguration()
        config.text = "\(user.displayName) (\(user.userID))"
        config.textProperties.numberOfLines = 1
        config.textProperties.lineBreakMode = .byTruncatingTail
        config.secondaryText = statusText(user.enabled)

        let color: UIColor = user.enabled ? .theme : .secondaryLabel
        config.secondaryTextProperties.color = color

        contentConfiguration = config
        accessoryType = .disclosureIndicator
    }

    private func statusText(_ status: Bool) -> String {
        return status == true ? .localized(.enabled) : .localized(.disabled)
    }
}
