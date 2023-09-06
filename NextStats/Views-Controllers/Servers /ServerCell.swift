//
//  ServerCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/20/20.
//  Copyright © 2020 Jon Alaniz. All Rights Reserved
//

import UIKit

class ServerCell: UITableViewCell {
    var server: NextServer!

    var serverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    var serverNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title2)

        return label
    }()

    var serverURLLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel

        return label
    }()

    var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)

        return label
    }()

    var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 2

        return stackView
    }()
}

extension ServerCell {
    func setup() {
        serverImageView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false

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

        if traitCollection.userInterfaceStyle == .light {
            #if !targetEnvironment(macCatalyst)
            backgroundColor = .quaternarySystemFill
            #endif
        }

        serverNameLabel.text = server?.name
        serverURLLabel.text = server?.friendlyURL

        serverImageView.image = server.serverImage()
    }

    func setOnlineStatus(to online: Bool) {
        if online {
            self.statusLabel.textColor = .systemGreen
            self.statusLabel.text = "Online"
        } else {
            self.statusLabel.textColor = .red
            self.statusLabel.text = "Unreachable"
        }

        self.statusLabel.layer.opacity = 0.8
        self.statusLabel.isHidden = false

        UIView.animate(withDuration: 0.4) {
            self.verticalStackView.layoutIfNeeded()
        }
    }
}
