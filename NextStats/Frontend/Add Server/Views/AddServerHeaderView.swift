//
//  AddServerHeaderView.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/12/23.
//  Copyright © 2023 Jon Alaniz. All rights reserved.
//

import UIKit

class AddServerHeaderView: UIView {
    let padding: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 200
        } else {
            return 50
        }
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "nextcloud-drive-connect"))
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    let activityIndicatior: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium

        return indicator
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.textColor = .statusLabelRed
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
    func setupView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatior.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(activityIndicatior)
        addSubview(statusLabel)

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            activityIndicatior.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatior.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -21),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            statusLabel.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
}
