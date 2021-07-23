//
//  ServerHeaderView.swift
//  ServerHeaderView
//
//  Created by Jon Alaniz on 7/22/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

struct ServerHeaderViewConstants {
    static let headerHeight: Int = {
        if widthIsConstrained { return 132 }
        return 140
    }()

    static let userString: String = {
        if widthIsConstrained { return "Users" }
        return "User Management"
    }()

    static let widthIsConstrained: Bool = {
        UIScreen.main.bounds.width == 320
    }()
}

class ServerHeaderView: UIView {

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10

        return stackView
    }()

    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 6

        return stackView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title1)
        label.numberOfLines = 0
        label.text = "My Server"

        return label
    }()

    let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.text = "cloud.jonalaniz.com"

        return label
    }()

    let userManagementButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .themeColor
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.sfSymbolWithText(symbol: "person.fill", text: ServerHeaderViewConstants.userString)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 14.0, bottom: 10.0, right: 14.0)

        return button
    }()

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 300, height: ServerHeaderViewConstants.headerHeight))
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(verticalStackView)
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(addressLabel)
        verticalStackView.addArrangedSubview(userManagementButton)

        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            imageView.widthAnchor.constraint(equalTo: heightAnchor, constant: -18),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }

    private func isWidthConstrained() -> Bool {
        return UIScreen.main.bounds.width == 321
    }

    func setupHeaderWith(name: String, address: String, image: UIImage) {
        nameLabel.text = name
        addressLabel.text = address
        imageView.image = image
    }

}
