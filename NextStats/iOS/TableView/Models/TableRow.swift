//
//  TableRow.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

struct TableRow {
    let title: String
    let titleColor: UIColor
    let secondaryText: String?
    let secondaryColor: UIColor
    let accessoryType: UITableViewCell.AccessoryType
    let action: (() -> Void)?
    let progressData: ProgressCellData?

    init(
        title: String,
        titleColor: UIColor = .theme,
        secondaryText: String?,
        secondaryColor: UIColor = .secondaryLabel,
        style: UITableViewCell.CellStyle = .value1,
        accessoryType: UITableViewCell.AccessoryType = .none,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.titleColor = titleColor
        self.secondaryText = secondaryText
        self.secondaryColor = secondaryColor
        self.accessoryType = accessoryType
        self.action = action
        self.progressData = nil
    }

    init(
        title: String,
        progressData: ProgressCellData
    ) {
        self.title = title
        self.titleColor = .theme
        self.secondaryText = nil
        self.secondaryColor = .secondaryLabel
        self.accessoryType = .none
        self.action = nil
        self.progressData = progressData
    }
}
