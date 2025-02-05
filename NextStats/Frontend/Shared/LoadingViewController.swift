//
//  LoadingViewController.swift
//  LoadingViewController
//
//  Created by Jon Alaniz on 7/25/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class LoadingViewController: UIViewController {
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background")
        imageView.layer.opacity = 0.5
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 16.0

        return stackView
    }()

    private let activityIndicator = UIActivityIndicatorView()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = .localized(.statsScreenFetchingData)
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .tertiaryLabel

        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        activityIndicator.startAnimating()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
        view.addSubview(stackView)

        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(textLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 180),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}
