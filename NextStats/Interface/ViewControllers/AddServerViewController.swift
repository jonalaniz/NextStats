//
//  AddServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class AddServerViewController: BaseTableViewController {
    weak var coordinator: AddServerCoordinator?

    let headerView = AddServerHeaderView()
    private var tableViewBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        tableViewHeaderView = headerView
        tableStyle = .insetGrouped
        titleText = .localized(.addScreenTitle)
        super.viewDidLoad()
        subscribeToKeyboardNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        tableViewBottomConstraint?.isActive = true
    }

    override func registerCells() {
        tableView.register(InputCell.self, forCellReuseIdentifier: InputCell.reuseidentifier)
    }

    func updateLabel(with text: String) {
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
        else { fatalError("Cannot cast cell as InputCell") }

        guard let urlString = urlCell.textField.text
        else {
            updateLabel(with: .localized(.serverFormEnterAddress))
            return
        }

        let name = nicknameCell.textField.text?.isEmpty == false ? nicknameCell.textField.text! : "Server"
        coordinator?.requestAuthorization(with: urlString, named: name)

    }

    @objc func cancelPressed() {
        coordinator?.dismiss()
    }

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

    /// Enables the connect button when text is entered
    func checkURLField() {
        // Safely unwrap urlString
        guard let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InputCell
        else {
            fatalError("Cannot cast cell as ServerInputCell")
        }

        guard let urlString = cell.textField.text else { return }

        urlString.isEmpty ? updateLabel(with: .localized(.serverFormEnterAddress)) : hideStatusAndEnableNextButton()
    }

    private func subscribeToKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillShow),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillDismiss),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }
}
