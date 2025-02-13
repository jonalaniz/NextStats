//
//  InputCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/12/23.
//  Copyright © 2023 Jon Alaniz.

import UIKit

class InputCell: BaseTableViewCell {
    var textField: UITextField!

    func setup() {
        self.selectionStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
