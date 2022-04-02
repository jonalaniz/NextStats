//
//  ServerHeaderView.swift
//  ServerHeaderView
//
//  Created by Jon Alaniz on 7/22/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

struct ServerHeaderViewConstants {
    static let headerHeight: Int = {
        return 320
    }()

    static let userString: NSAttributedString = {
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: " Users "))
        string.prefixingSFSymbol("person.fill", color: .white)
        string.suffixingSFSymbol("chevron.right", color: .white)

        return string
    }()
}

class ServerHeaderView: UIView {

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10

        return stackView
    }()

    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 6

        return stackView
    }()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
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
        let button = UIButton()
        button.backgroundColor = .themeColor
        button.layer.cornerRadius = 10

        button.setAttributedTitle(ServerHeaderViewConstants.userString, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 14.0, bottom: 12.0, right: 14.0)

        return button
    }()

    let visitServerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .themeColor
        button.layer.cornerRadius = 10
        button.sfSymbolWithText(symbol: "safari.fill",
                                text: .localized(.serverHeaderVisit),
                                color: .white)
        button.titleLabel?.font = .preferredFont(forTextStyle: .callout)
        button.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 14.0, bottom: 12.0, right: 14.0)

        return button
    }()

    let spacerView = UIView()

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
        mainStackView.addArrangedSubview(nameLabel)
        mainStackView.addArrangedSubview(addressLabel)
        mainStackView.addArrangedSubview(buttonStackView)
//        buttonStackView.addArrangedSubview(users)
        buttonStackView.addArrangedSubview(visitServerButton)
        mainStackView.addArrangedSubview(spacerView)

        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 18),
            mainStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -18),
            imageView.widthAnchor.constraint(equalToConstant: 180),
            imageView.heightAnchor.constraint(equalToConstant: 180),
            spacerView.heightAnchor.constraint(equalToConstant: 10)
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
