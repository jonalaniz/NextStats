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
    var user: User!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        setupView()
    }

    func setupView() {
        view.backgroundColor = .systemBackground
        title = user.data.displayname

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

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

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Email"
        case 1:
            guard user.data.quota.quota! > 0 else {
                return "Quota (Unlimited)"
            }

            return "Quota"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let additionalMail = user.data.additionalMail
            else {
                return 1
            }
            print(additionalMail)

            // figure out if additionalMail is String or [String]
            // Then either return 2 or array.count + 1
            switch additionalMail.element {
            case .string(let string):
                return 2
            case .stringArray(let array):
                return array.count + 1
            default:
                return 1
            }
        case 1: return 1
        case 2: return 8
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 66
        default: return 44
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = "Primary"
                cell.textLabel?.text = user.data.email
            case 1:
                switch user.data.additionalMail?.element {
                case .string(let string):
                    cell.textLabel?.text = string
                case .stringArray(let array):
                    cell.textLabel?.text = array.first
                case nil:
                    break
                }
            default:
                switch user.data.additionalMail?.element {
                case .stringArray(let array):
                    cell.textLabel?.text = array[indexPath.row - 1]
                default:
                    break
                }
            }

            return cell
        case 1:
            let cell = QuotaCell(style: .default, reuseIdentifier: "QuotaCell")
            cell.setProgress(with: user.data.quota)
            cell.isUserInteractionEnabled = false
            return cell
        default:
            let cell = UITableViewCell()
            cell.textLabel?.backgroundColor = .red
            cell.textLabel?.text = "Test"
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
}

class QuotaCell: UITableViewCell {
    var quotaLabel = UILabel()
    var quotaProgressView = UIProgressView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        quotaProgressView.tintColor = .themeColor
        quotaLabel.translatesAutoresizingMaskIntoConstraints = false
        quotaProgressView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quotaLabel)
        contentView.addSubview(quotaProgressView)

        NSLayoutConstraint.activate([
            // Constrain the quotaLabel
            quotaLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            quotaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            quotaLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            quotaLabel.bottomAnchor.constraint(equalTo: quotaProgressView.topAnchor),

            // Constrain our storageView
            quotaProgressView.heightAnchor.constraint(equalToConstant: 4),
            quotaProgressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            quotaProgressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            quotaProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func setProgress(with quota: Quota) {
        guard
            let progressFloat = quota.relative,
            let free = quota.free,
            let used = quota.used,
            let total = quota.total,
            let quota = quota.quota
        else { return }

        let freeString = Units(bytes: Double(free)).getReadableUnit()
        let usedString = Units(bytes: Double(used)).getReadableUnit()
        let totalString = Units(bytes: Double(total)).getReadableUnit()

        var quotaString = ""

        // Check if there is a quota
        if quota < 0 {
            // Negative quotas mean no quota (Unlimited).
            quotaString = "\(usedString) of \(totalString) Used"
        } else {
            let quotaUnit = Units(bytes: Double(quota))
            quotaString = "\(used) of \(quotaUnit.getReadableUnit())"
        }

        quotaLabel.text = quotaString

        // Nextcloud gives a literal representation of the percentage
        // 0.3 = 0.3% in this case
        let correctedProgress = Float(progressFloat / 100)
        quotaProgressView.progress = correctedProgress
    }
}
