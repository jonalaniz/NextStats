//
//  UsersViewController.swift
//  UsersViewController
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class UsersViewController: UIViewController {
    weak var coordinator: UsersCoordinator?

    let usersDataManager = NXUsersManager.shared
    let loadingViewController = LoadingViewController()
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        usersDataManager.fetchUsersData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Deselect row when returning to view
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    private func setupView() {
        title = "Users"
        view.backgroundColor = .systemBackground

        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: nil)

        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserCell.self, forCellReuseIdentifier: "Cell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        add(loadingViewController)
        tableView.isHidden = true
    }

    func showTableView() {
        tableView.reloadData()
        tableView.isHidden = false
        loadingViewController.remove()
    }

    @objc func dismissController() {
        coordinator?.didFinish()
        dismiss(animated: true, completion: nil)
    }
}

extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersDataManager.usersCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UserCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.user = usersDataManager.userCellModel(indexPath.row)
        cell.setup()

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userCellModel = usersDataManager.userCellModel(indexPath.row)
        let user = usersDataManager.user(id: userCellModel.userID)

        coordinator?.showUserView(for: user)
    }
}

extension UsersViewController: NXDataManagerDelegate {
    // TODO: Implement error handling
    func stateDidChange(_ dataManagerState: NXDataManagerState) {
        switch dataManagerState {
        case .fetchingData:
            // Fetch Data
            return
        case .parsingData:
            // Parse Data
            return
        case .failed(let error):
            // Error
            print(error.description)
            return
        case .dataCaptured:
            tableView.reloadData()
            showTableView()
        }
    }
}
