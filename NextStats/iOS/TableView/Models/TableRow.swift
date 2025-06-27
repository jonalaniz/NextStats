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
    let secondaryText: String?
    let style: UITableViewCell.CellStyle
    let accessoryType: UITableViewCell.AccessoryType
    let custom: Bool
    let action: (() -> Void)?
    let progressData: ProgressCellData?

    init(
        title: String,
        secondaryText: String?,
        style: UITableViewCell.CellStyle = .value1,
        accessoryType: UITableViewCell.AccessoryType = .none,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.secondaryText = secondaryText
        self.style = style
        self.accessoryType = accessoryType
        self.custom = false
        self.action = action
        self.progressData = nil
    }

    init(
        title: String,
        progressData: ProgressCellData
    ) {
        self.title = title
        self.secondaryText = nil
        self.style = .default
        self.accessoryType = .none
        self.custom = true
        self.action = nil
        self.progressData = progressData
    }
}
