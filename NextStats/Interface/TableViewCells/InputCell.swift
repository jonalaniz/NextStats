//
//  InputCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/12/23.
//  Copyright © 2023 Jon Alaniz.

import UIKit

class InputCell: BaseTableViewCell {
    static let reuseidentifier = "InputCell"

    var textField: UITextField!

    convenience init(style: UITableViewCell.CellStyle) {
        self.init(
            style: style,
            reuseIdentifier: InputCell.reuseidentifier
        )
    }

    func setup() {
        self.selectionStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textField)

        let padding: CGFloat = 12.0
        let sidePadding: CGFloat = 2.0

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: padding
            ),
            textField.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -padding
            ),
            textField.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: sidePadding
            ),
            textField.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -sidePadding
            )
        ])
    }
}
