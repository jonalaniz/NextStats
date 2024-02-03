//
//  HeaderView.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/17/21.
//  Copyright © 2021 Jon Alaniz.

import UIKit

class HeaderView: UIView {
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill

        return stackView
    }()

    let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading

        return stackView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "nextstat-logo")
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    let appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.text = "NextStats"

        return label
    }()

    let versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        label.text = UIApplication.appVersion

        return label
    }()

    let createdByLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .tertiaryLabel
        label.text = "Created by Jon Alaniz"

        return label
    }()

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 300, height: 140))
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        labelStackView.addArrangedSubview(appNameLabel)
        labelStackView.addArrangedSubview(versionLabel)
        labelStackView.addArrangedSubview(createdByLabel)

        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(labelStackView)

        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),

            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
