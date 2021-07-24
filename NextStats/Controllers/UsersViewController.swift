//
//  UsersViewController.swift
//  UsersViewController
//
//  Created by Jon Alaniz on 7/23/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import UIKit

class UsersViewController: UIViewController {
    weak var coordinator: UsersCoordinator?

    let usersDataManager = UserDataManager.shared
    let loadingView = LoadingView()
    let tableView = UITableView(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        usersDataManager.fetchUsers()
    }

    private func setupView() {
        title = "User Management"
        view.backgroundColor = .systemBackground
        usersDataManager.delegate = self

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(dismissController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: nil)

        view.addSubview(tableView)
        view.addSubview(loadingView)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loadingView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])

        tableView.isHidden = true
    }

    private func showTableView() {
        tableView.reloadData()
        tableView.isHidden = false
        loadingView.isHidden = true
    }

    @objc func dismissController() {
        coordinator?.didFinish()
        dismiss(animated: true, completion: nil)
    }
}

extension UsersViewController: UsersDelegate {
    func didRecieveUsers() {
        showTableView()
    }
}

extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersDataManager.userIDs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = usersDataManager.userIDs[indexPath.row]
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}
