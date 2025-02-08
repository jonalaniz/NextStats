//
//  LoadingViewController.swift
//  LoadingViewController
//
//  Created by Jon Alaniz on 7/25/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class LoadingViewController: BaseViewController {
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
        activityIndicator.startAnimating()
    }

    override func setupView() {
        super.setupView()
        view.addSubview(stackView)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(textLabel)
    }

    override func constrainView() {
        super.constrainView()
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalToConstant: 180),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}
