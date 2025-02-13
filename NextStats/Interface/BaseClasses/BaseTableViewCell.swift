//
//  BaseTableViewCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/13/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        backgroundView = self.blurView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
