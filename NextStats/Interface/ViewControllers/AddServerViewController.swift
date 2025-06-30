//
//  AddServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class AddServerViewController: BaseTableViewController {
    // MARK: - Properties

    let headerView = AddServerHeaderView()
    private var tableViewBottomConstraint: NSLayoutConstraint?

    weak var coordinator: AddServerCoordinator?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        prefersLargeTitles = false
        tableViewHeaderView = headerView
        tableStyle = .insetGrouped
        titleText = .localized(.addScreenTitle)
        super.viewDidLoad()
        setupKeyboardNotifications()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - Configuration

    private func setupKeyboardNotifications() {
        subscribeTo(
            UIResponder.keyboardWillShowNotification,
            with: #selector(keyboardWillShow)
        )

        subscribeTo(
            UIResponder.keyboardWillHideNotification,
            with: #selector(keyboardWillDismiss)
        )
    }

    override func setupNavigationController() {
        let nextButton = UIBarButtonItem(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(nextButtonPressed))
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed))

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func setupTableView() {
        super.setupTableView()
        tableView.alwaysBounceVertical = false
        tableView.rowHeight = 44
        tableView.sectionHeaderHeight = 28
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor
        )
        tableViewBottomConstraint?.isActive = true
    }

    override func registerCells() {
        tableView.register(
            InputCell.self,
            forCellReuseIdentifier: InputCell.reuseidentifier
        )
    }

    // MARK: - Actions

    @objc func cancelPressed() {
        coordinator?.didFinish()
    }

    @objc func nextButtonPressed(_ sender: Any) {
        guard
            let urlCell = tableView.cellForRow(
                at: IndexPath(row: 1, section: 0)
            ) as? InputCell,
            let nicknameCell = tableView.cellForRow(
                at: IndexPath(row: 0, section: 0)
            ) as? InputCell
        else { fatalError("Cannot cast cell as InputCell") }

        guard let urlString = urlCell.textField.text
        else {
            updateLabel(with: .localized(.serverFormEnterAddress))
            return
        }

        let name = nicknameCell.textField.text?.isEmpty == false ? nicknameCell.textField.text! : "Server"
        coordinator?.requestAuthorization(
            with: urlString, named: name
        )
    }

    // MARK: - UI Updates

    func updateLabel(with text: String) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        headerView.statusLabel.isHidden = false
        headerView.statusLabel.text = text
        headerView.activityIndicatior.deactivate()
    }

    private func toggleAuthentication(enabled: Bool) {
        if !enabled { updateLabel(with: .localized(.serverFormEnterAddress)) }
        headerView.statusLabel.isHidden = enabled
        navigationItem.rightBarButtonItem?.isEnabled = enabled
    }

    // MARK: - Keyboard Handling

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let info = notification.userInfo,
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        tableViewBottomConstraint?.constant = -keyboardFrame.height

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }

        self.tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .bottom, animated: true)
    }

    @objc private func keyboardWillDismiss(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        tableViewBottomConstraint?.constant = 0

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Helper Methods
    private func subscribeTo(_ name: Notification.Name, with selector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: selector,
            name: name,
            object: nil
        )
    }
}

// MARK: - AuthenticationDataSourceDelegate

extension AddServerViewController: AuthenticationDataSourceDelegate {
    func didEnterURL(_ url: String) {
        toggleAuthentication(enabled: !url.isEmpty)
    }
}
