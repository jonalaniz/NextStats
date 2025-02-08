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
class UserCell: UITableViewCell {
    /// The user model assigned to this cell.
    private(set) var user: UserCellModel!

    /// Returns the localized enabled/disabled status text.
    private var statusText: String {
        return user?.enabled == true ? .localized(.enabled) : .localized(.disabled)
    }

    /// Configures the cell with a user model.
    func configureCell(with user: UserCellModel) {
        self.user = user
        setup()
    }

    /// Sets up the UI content configuration for the cell
    private func setup() {
        guard let user = user else { return }

        var content = defaultContentConfiguration()
        content.text = "\(user.displayName) (\(user.userID))"
        content.textProperties.numberOfLines = 1
        content.textProperties.lineBreakMode = .byTruncatingTail
        content.secondaryText = statusText

        let color: UIColor = user.enabled ? .theme : .secondaryLabel
        content.secondaryTextProperties.color = color

        contentConfiguration = content
        accessoryType = .disclosureIndicator
    }
}
