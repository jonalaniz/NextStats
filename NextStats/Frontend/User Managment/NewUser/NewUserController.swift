//
//  NewUserController.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/15/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class NewUserController: UIViewController {
    weak var coordinator: NewUserCoordinator?

    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupView()
    }

    private func setupNavigationController() {
        title = "New User"
        navigationController?.navigationBar.prefersLargeTitles = true

        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel,
                                     target: self,
                                     action: #selector(cancelPressed))
        let done = UIBarButtonItem(barButtonSystemItem: .done,
                                   target: self,
                                   action: #selector(donePressed))

        navigationItem.leftBarButtonItem = cancel
        navigationItem.rightBarButtonItem = done
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func setupView() {
        tableView.register(InputCell.self, forCellReuseIdentifier: "InputCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    @objc func cancelPressed() {
        coordinator?.dismiss()
    }

    @objc func donePressed() {
        coordinator?.createUser()
    }
}
