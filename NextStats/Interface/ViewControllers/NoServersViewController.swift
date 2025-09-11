//
//  NoServersViewController.swift
//  NoServersViewController
//
//  Created by Jon Alaniz on 7/25/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

final class NoServersViewController: BaseViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16.0

        return stackView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.clear.image
        imageView.layer.cornerRadius = 38
        imageView.clipsToBounds = true

        return imageView
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = .localized(.noServersLabel)
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .tertiaryLabel

        return label
    }()

    override func setupView() {
        super.setupView()
        view.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textLabel)
    }

    // TODO: Fix alignment with pre and post iOS 26
    override func constrainView() {
        super.constrainView()
        NSLayoutConstraint.activate([
            iconImageView.heightAnchor.constraint(equalToConstant: 180),
            iconImageView.widthAnchor.constraint(equalToConstant: 180),
            textLabel.widthAnchor.constraint(equalToConstant: 180),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60)
        ])
    }
}
