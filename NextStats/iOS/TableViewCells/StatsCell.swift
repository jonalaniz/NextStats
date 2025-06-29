//
//  StatsCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/29/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class StatsCell: BaseTableViewCell {
    static let reuseIdentifier = "StatsCell"

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?) {
        super.init(
            style: .value1,
            reuseIdentifier: StatsCell.reuseIdentifier
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configures the cell with TableRow data..
    func configureCell(with cellData: TableRow) {
        var configuration = defaultContentConfiguration()
        configuration.text = cellData.title
        configuration.textProperties.color = .theme
        configuration.secondaryText = cellData.secondaryText
        contentConfiguration = configuration
    }
}
