//
//  AddServerHeaderView.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/12/23.
//  Copyright © 2023 Jon Alaniz. All rights reserved.
//

import UIKit

class AddServerHeaderView: UIView {
    private let padding: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 200
        } else {
            return 50
        }
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: ImageAsset.connectImage.image)
        imageView.contentMode = .scaleAspectFit
        imageView.addGlow()

        return imageView
    }()

    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .medium

        return indicator
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textColor = .themeRed
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = .localized(.addScreenStatusLabel)

        return label
    }()

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 700, height: 140))
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(indicator)
        addSubview(statusLabel)

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -21),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            statusLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    func updateLabel(with text: String) {
        statusLabel.isHidden = false
        statusLabel.text = text
        indicator.deactivate()
    }

    func enableIndicator(_ enabled: Bool) {
        guard indicator.isAnimating == enabled else { return }
        if enabled {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }
}
