//
//  ServerFormView.swift
//  NextStats
//
//  Created by Jon Alaniz on 5/19/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

class ServerFormView: UIView {
     let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 12

        return stackView
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.secondaryLabel
        label.text = "server_nickname".localized()

        return label
    }()

    let nicknameField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.backgroundColor = .systemFill
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: "MyServer",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.quaternaryLabel])

        return textField
    }()

    private let serverURLLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.secondaryLabel
        label.text = "server_url".localized()

        return label
    }()

    let serverURLField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textContentType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .URL
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.backgroundColor = .systemFill
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: "https://cloud.example.com",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.quaternaryLabel])

        return textField
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = "info_label".localized()

        return label
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.textColor = UIColor(red: 255/255, green: 42/255, blue: 85/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.text = "status_label".localized()

        return label
    }()

    let activityIndicatior: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .medium
        indicator.color = .white
        indicator.isHidden = true

        return indicator
    }()

    private let paddingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.themeColor
        button.layer.cornerRadius = 10
        button.setTitle("connect".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
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
        // Setup View
        self.backgroundColor = .systemBackground

        // Style the UI
        styleTextField(textField: nicknameField)
        styleTextField(textField: serverURLField)

        // Arrange subviews
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

        nicknameField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        serverURLField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        connectButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        paddingView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        stackView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -32).isActive = true
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
    }

    private func styleTextField(textField: UITextField) {
        // Style the textFields
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))

        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
        textField.borderStyle = .none
        textField.layoutIfNeeded()
        textField.layer.cornerRadius = 10
    }
}
