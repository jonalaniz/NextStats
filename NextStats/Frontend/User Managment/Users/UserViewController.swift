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
    let dataManager = NXUserFormatter.shared

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
        title = dataManager.title()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self

        tableView.register(ProgressCell.self, forCellReuseIdentifier: "QuotaCell")

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}

extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldHide(section: section) ? CGFloat.leastNonzeroMagnitude : 20
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableSection = UserDataSection(rawValue: indexPath.section)
        else { return 44 }

        return tableSection.height()
    }

    func shouldHide(section: Int) -> Bool {
        guard let tableSection = UserDataSection(rawValue: section)
        else { return false }

        switch tableSection {
        case .mail: return dataManager.emailAddresses() == nil
        default: return false
        }
    }
}
