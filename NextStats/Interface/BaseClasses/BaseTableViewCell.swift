//
//  BaseTableViewCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/13/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

/// A base class for table view cells that provides a blurred background and a convenience initializer
/// for quick configuration of text, color, interactivity, and accessory types.
class BaseTableViewCell: UITableViewCell {
    static let baseReuseIdentifier = "BaseTableViewCell"

    /// Initializes a table view cell with the specified style and reuse identifier.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        backgroundView = self.blurView
    }

    /// Convenience initializer for quickly configuring a `BaseTableViewCell` with common properties.
    /// - Parameters:
    ///   - style: The style of the cell.
    ///   - text: The main text displayed in the cell.
    ///   - textColor: The color of the text, defaulting to `.label`.
    ///   - isInteractive: A boolean indicating whether the cell is interactive, defaulting to `true`.
    ///   - accessoryType: The accessory type (e.g., `.none`, `.disclosureIndicator`), defaulting to `.none`.
    convenience init(style: UITableViewCell.CellStyle,
                     text: String,
                     textColor: UIColor = .label,
                     secondaryText: String? = nil,
                     secondaryTextColor: UIColor = .secondaryLabel,
                     isInteractive: Bool = true,
                     accessoryType: UITableViewCell.AccessoryType = .none) {
        self.init(style: style, reuseIdentifier: BaseTableViewCell.baseReuseIdentifier)
        var content = defaultContentConfiguration()
        content.text = text
        content.textProperties.color = textColor
        content.secondaryText = secondaryText
        content.secondaryTextProperties.color = secondaryTextColor

        contentConfiguration = content
        isUserInteractionEnabled = isInteractive
        self.accessoryType = accessoryType
    }

    /// Required initializer for decoding from a storyboard or nib. Not implemented for this class.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
