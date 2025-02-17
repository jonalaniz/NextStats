//
//  SelectServerViewController.swift
//  SelectServerViewController
//
//  Created by Jon Alaniz on 7/25/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class SelectServerViewController: BaseViewController {
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .localized(.statsScreenSelectLabel)
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .tertiaryLabel

        return label
    }()

    override func setupView() {
        super.setupView()
        view.addSubview(textLabel)
    }

    override func constrainView() {
        super.constrainView()
        NSLayoutConstraint.activate([
            textLabel.widthAnchor.constraint(equalToConstant: 250),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
