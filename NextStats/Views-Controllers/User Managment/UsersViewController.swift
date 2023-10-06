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

    private func setupView() {
        title = "User Management"
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: nil)

        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

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
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = usersDataManager.userID(indexPath.row)
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // coordinator?.showUserView(for: usersDataManager.userID(indexPath.row))
        usersDataManager.fetch(user: usersDataManager.userID(indexPath.row))
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
            return
        case .dataCaptured:
            showTableView()
        }
    }
}
