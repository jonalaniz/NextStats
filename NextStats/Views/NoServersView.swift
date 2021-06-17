//
//  NoServersView.swift
//  NextStats
//
//  Created by Jon Alaniz on 5/23/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

class NoServersView: UIView {
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
        imageView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        imageView.image = UIImage(named: "Greyscale-Icon")
        imageView.layer.cornerRadius = 38
        imageView.clipsToBounds = true

        return imageView
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.widthAnchor.constraint(equalToConstant: 180).isActive = true
        label.text = "You do not have any servers"
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .tertiaryLabel

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createSubviews()
    }

    private func createSubviews() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textLabel)

        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

}
