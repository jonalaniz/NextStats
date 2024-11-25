//
//  ServerCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/20/20.
//  Copyright © 2020 Jon Alaniz. All Rights Reserved
//

import UIKit

enum ServerStatus {
    case online
    case offline
    case maintenance
}

class ServerCell: UITableViewCell {
    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true

        return imageView
    }()

    private var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThickMaterial)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.clipsToBounds = true

        return effectView
    }()

    private var serverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private var serverNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)
        #if targetEnvironment(macCatalyst)
        label.textColor = .label
        #else
        label.textColor = .themeColor
        #endif
        return label
    }()

    private var serverURLLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        return label
    }()

    private var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    private var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateBlurViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        updateBlurViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        accessoryType = .disclosureIndicator
        backgroundColor = .clear

        addSubview(backgroundImageView)
        addSubview(blurEffectView)

        contentView.addSubview(serverImageView)
        contentView.addSubview(verticalStackView)

        verticalStackView.addArrangedSubview(serverNameLabel)
        verticalStackView.addArrangedSubview(serverURLLabel)
        verticalStackView.addArrangedSubview(statusLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),

            serverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            serverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            serverImageView.heightAnchor.constraint(equalToConstant: 78),
            serverImageView.widthAnchor.constraint(equalToConstant: 78),

            verticalStackView.leadingAnchor.constraint(equalTo: serverImageView.trailingAnchor, constant: 10),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            verticalStackView.centerYAnchor.constraint(equalTo: serverImageView.centerYAnchor)
        ])
    }

    func configure(with server: NextServer) {
        serverNameLabel.text = server.name
        serverURLLabel.text = server.friendlyURL
        serverImageView.image = server.serverImage()
        backgroundImageView.image = server.serverImage()
    }

    func setStatus(to status: ServerStatus) {
        switch status {
        case .online:
            statusLabel.text = "Online"
            statusLabel.textColor = .statusLabelGreen
        case .offline:
            statusLabel.text = "Offline"
            statusLabel.textColor = .statusLabelRed
        case .maintenance:
            statusLabel.text = "Maintenance"
            statusLabel.textColor = .systemYellow
        }

        statusLabel.layer.opacity = 0.8
        statusLabel.isHidden = false

        UIView.animate(withDuration: 0.4) {
            self.verticalStackView.layoutIfNeeded()
        }
    }

    private func updateBlurViews() {
        let currentMode = UIScreen.main.traitCollection.userInterfaceStyle
        let selectedBlur: UIBlurEffect.Style = currentMode == .light ? .systemUltraThinMaterial : .prominent
        let deselectedBlur: UIBlurEffect.Style = currentMode == .light ? .systemThickMaterial : .regular
        let selected = self.isSelected

        let effect = selected ? UIBlurEffect(style: selectedBlur) : UIBlurEffect(style: deselectedBlur)
        blurEffectView.effect = effect
    }
}
