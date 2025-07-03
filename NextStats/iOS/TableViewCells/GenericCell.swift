//
//  GenericCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/29/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class GenericCell: BaseTableViewCell {
    static let reuseIdentifier = "GenericCell"

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?) {
        super.init(
            style: .subtitle,
            reuseIdentifier: GenericCell.reuseIdentifier
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
        configuration.secondaryTextProperties.color = .secondaryLabel
        configuration.secondaryTextProperties.numberOfLines = 0
        configuration.secondaryTextProperties.lineBreakMode = .byCharWrapping
        contentConfiguration = configuration
        accessoryType = cellData.accessoryType
        selectionStyle = .none
    }
}
