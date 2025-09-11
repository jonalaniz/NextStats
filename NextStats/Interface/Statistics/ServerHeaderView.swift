//
//  ServerHeaderView.swift
//  ServerHeaderView
//
//  Created by Jon Alaniz on 7/22/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

final class ServerHeaderView: UIView {

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

    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.addGlow(opacity: 0.1)
        return stackView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.addGlow()

        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .theme
        label.numberOfLines = 0

        return label
    }()

    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel

        return label
    }()

    let users: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .cellBackground
        config.cornerStyle = .medium
        config.image = SFSymbol.user.image
        config.title = .localized(.users)
        config.baseForegroundColor = .theme
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 14, bottom: 13, trailing: 14)

        let button = UIButton(configuration: config, primaryAction: nil)
        return button
    }()

    let visitServerButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .cellBackground
        config.cornerStyle = .medium
        config.image = SFSymbol.safari.image
        config.title = .localized(.serverHeaderVisit)
        config.baseForegroundColor = .theme
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 14, bottom: 13, trailing: 14)

        let button = UIButton(configuration: config, primaryAction: nil)
        return button
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
        mainStackView.addArrangedSubview(addressLabel)

        if !SystemVersion.isiOS26 {
            mainStackView.addArrangedSubview(buttonStackView)
            buttonStackView.addArrangedSubview(users)
            buttonStackView.addArrangedSubview(visitServerButton)
        }

        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }

    func setupHeaderWith(name: String, address: String, image: UIImage) {
        nameLabel.text = name
        addressLabel.text = address
        imageView.image = image
    }
}
