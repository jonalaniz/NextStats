//
//  ServerFormView.swift
//  NextStats
//
//  Created by Jon Alaniz on 5/19/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.

import UIKit

class ServerFormView: UIView {
     let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 12

        return stackView
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = .localized(.addScreenNickname)

        return label
    }()

    let nicknameField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.backgroundColor = .systemFill
        textField.font = .systemFont(ofSize: 16)
        textField.attributedPlaceholder = "My Server".attributedWithQuaternaryColor()

        return textField
    }()

    private let serverURLLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = .localized(.addScreenUrl)

        return label
    }()

    let serverURLField: UITextField = {
        let textField = UITextField()
        textField.textContentType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .URL
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.backgroundColor = .systemFill
        textField.font = .systemFont(ofSize: 16)
        textField.attributedPlaceholder = "https://cloud.example.com".attributedWithQuaternaryColor()

        return textField
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = .localized(.addScreenLabel)

        return label
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

    let activityIndicatior: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.color = .white
        indicator.isHidden = true

        return indicator
    }()

    private let paddingView: UIView = {
        let view = UIView()

        return view
    }()

    let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .themeColor
        button.layer.cornerRadius = 10
        button.setTitle(.localized(.addScreenConnect), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.isEnabled = false

        return button
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
        self.backgroundColor = .systemBackground

        styleTextField(textField: nicknameField)
        styleTextField(textField: serverURLField)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(nicknameField)
        stackView.addArrangedSubview(serverURLLabel)
        stackView.addArrangedSubview(serverURLField)
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(activityIndicatior)
        stackView.addArrangedSubview(paddingView)
        stackView.addArrangedSubview(connectButton)

        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            nicknameField.heightAnchor.constraint(equalToConstant: 44),
            serverURLField.heightAnchor.constraint(equalToConstant: 44),
            connectButton.heightAnchor.constraint(equalToConstant: 44),
            paddingView.heightAnchor.constraint(equalToConstant: 10),
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -32),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor)
        ])
    }

    private func styleTextField(textField: UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))

        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.borderStyle = .none
        textField.layoutIfNeeded()
        textField.layer.cornerRadius = 10
    }
}
