//
//  AddServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class AddServerViewController: UIViewController {
    weak var coordinator: AddServerCoordinator?

    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let headerView = AddServerHeaderView()

    override func loadView() {
        super.loadView()
        setupNavigationController()
        setupView()
    }

    private func setupNavigationController() {
        title = .localized(.addScreenTitle)
        navigationController?.navigationBar.prefersLargeTitles = true

        let nextButton = UIBarButtonItem(title: "Next",
                                         style: .plain,
                                         target: self,
                                         action: #selector(nextButtonPressed))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                           target: self,
                                           action: #selector(cancelPressed))

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.isEnabled = false

    }

    private func setupView() {
        tableView.tableHeaderView = headerView
        tableView.register(InputCell.self, forCellReuseIdentifier: "InputCell")
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let backgroundView = UIImageView(image: UIImage(named: "background"))
        backgroundView.layer.opacity = 0.5
        tableView.backgroundView = backgroundView

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    func updateStatusLabel(with text: String) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        headerView.statusLabel.isHidden = false
        headerView.statusLabel.text = text
        headerView.activityIndicatior.deactivate()
    }

    private func hideStatusAndEnableNextButton() {
        headerView.statusLabel.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    @objc func nextButtonPressed(_ sender: Any) {
        guard
            let urlCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InputCell,
            let nicknameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InputCell
        else {
            fatalError("Cannot cast cell as ServerInputCell")
        }

        guard let urlString = urlCell.textField.text
        else {
            updateStatusLabel(with: .localized(.serverFormEnterAddress))
            return
        }

        guard
            let name = nicknameCell.textField.text,
            name != ""
        else {
            coordinator?.requestAuthorization(with: urlString, named: "Server")
            return
        }

        coordinator?.requestAuthorization(with: urlString, named: name)

    }

    @objc func cancelPressed() {
        coordinator?.dismiss()
    }

    /// Enables the connect button when text is entered
    func checkURLField() {
        // Safely unwrap urlString
        guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InputCell
        else {
            fatalError("Cannot cast cell as ServerInputCell")
        }

        guard let urlString = cell.textField.text else { return }

        if urlString != "" {
            hideStatusAndEnableNextButton()
        } else {
            updateStatusLabel(with: .localized(.serverFormEnterAddress))
        }
    }
}

// MARK: - TableViewDelegate
extension AddServerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
