//
//  UserViewController.swift
//  UserViewController
//
//  Created by Jon Alaniz on 7/31/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class UserViewController: UIViewController {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    let userDataManager = NXUserDataManager.shared

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        view.backgroundColor = .systemBackground
        title = userDataManager.title()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = userDataManager
        tableView.dataSource = userDataManager

        // Register our cells
        tableView.register(QuotaCell.self, forCellReuseIdentifier: "QuotaCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
