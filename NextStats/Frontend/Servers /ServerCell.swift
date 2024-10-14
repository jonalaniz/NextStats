//
//  ServerCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/20/20.
//  Copyright © 2020 Jon Alaniz. All Rights Reserved
//

import UIKit

class ServerCell: UITableViewCell {
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        accessoryType = .disclosureIndicator

        contentView.addSubview(serverImageView)
        contentView.addSubview(verticalStackView)

        verticalStackView.addArrangedSubview(serverNameLabel)
        verticalStackView.addArrangedSubview(serverURLLabel)
        verticalStackView.addArrangedSubview(statusLabel)

        NSLayoutConstraint.activate([
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
    }

    func setOnlineStatus(to isOnline: Bool) {
        statusLabel.text = isOnline ? "Online" : "Unreachable"
        statusLabel.textColor = isOnline ? .statusLabelGreen : .statusLabelRed
        statusLabel.layer.opacity = 0.8
        statusLabel.isHidden = false

        UIView.animate(withDuration: 0.4) {
            self.verticalStackView.layoutIfNeeded()
        }
    }
}
