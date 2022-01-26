//
//  SelectServerViewController.swift
//  SelectServerViewController
//
//  Created by Jon Alaniz on 7/25/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

class SelectServerViewController: UIViewController {
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = .localized(.statsScreenSelectLabel)
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .tertiaryLabel

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.widthAnchor.constraint(equalToConstant: 250),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
