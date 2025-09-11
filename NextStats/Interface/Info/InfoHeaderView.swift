//
//  HeaderView.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/17/21.
//  Copyright © 2021 Jon Alaniz.

import UIKit

class InfoHeaderView: UIView {
    // MARK: - Properties

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 6

        return stackView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = AppIcon.normal.image
        imageView.addGlow()

        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .theme
        label.numberOfLines = 0
        label.text = "NextStats"

        return label
    }()

    let versionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.text = UIApplication.appVersion

        return label
    }()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Configuration

    private func setupView() {
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(versionLabel)

        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
}

class InfoHeaderViewX: UIView {
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
        imageView.image = AppIcon.normal.image
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    let appNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textColor = .theme
        label.text = "NextStats"

        return label
    }()

    let versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.text = UIApplication.appVersion

        return label
    }()

    let createdByLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
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
