//
//  QuotaCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/26/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

enum ProgressCellIcon {
    case storage, memory, swap
}

class ProgressCell: UITableViewCell {
    var iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    var detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No data available"
        label.textAlignment = .right
        label.textColor = .secondaryLabel

        return label
    }()

    var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .theme

        return progressView
    }()

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    convenience init(quota: Quota) {
        self.init(reuseIdentifier: "QuotaCell")
        setProgress(with: quota)
        set(icon: .storage)
    }

    convenience init(free: Int, total: Int, type: ProgressCellIcon) {
        self.init(reuseIdentifier: "MemoryCell")
        set(icon: type)
        setProgress(free: free, total: total)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        isUserInteractionEnabled = false
        contentView.addSubview(iconLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(progressView)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconLabel.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 100),
            iconLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor),

            detailLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor),

            progressView.heightAnchor.constraint(equalToConstant: 4),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    private func set(icon: ProgressCellIcon) {
        let string = NSMutableAttributedString()

        switch icon {
        case .storage:
            string.prefixingSFSymbol("internaldrive", color: .theme)
        case .memory:
            string.prefixingSFSymbol("memorychip", color: .theme)
            string.append(NSAttributedString(string: " RAM", attributes: [.foregroundColor: UIColor.theme]))
        case .swap:
            string.prefixingSFSymbol("memorychip.fill", color: .theme)
            string.append(NSAttributedString(string: " Swap", attributes: [.foregroundColor: UIColor.theme]))
        }
        iconLabel.attributedText = string
    }

    private func setProgress(free: Int, total: Int) {
        let used = total - free
        let usedString = Units(kilobytes: Double(used)).getReadableUnit()
        let totalString = Units(kilobytes: Double(total)).getReadableUnit()
        let label = "\(usedString) of \(totalString) Used"

        detailLabel.text = label

        let progress = Float(used) / Float(total)
        progressView.progress = progress
    }

    private func setProgress(with quota: Quota) {
        switch quota.quota {
        case .int(let int):
            guard
                let progressFloat = quota.relative,
                let used = quota.used,
                let total = quota.total
            else { return }

            let usedString = Units(bytes: Double(used)).getReadableUnit()
            let totalString = Units(bytes: Double(total)).getReadableUnit()

            var quotaString = ""

            // Check if there is a quota
            if int < 0 {
                // Negative quotas mean no quota (Unlimited).
                quotaString = "\(usedString) of \(totalString) Used"
            } else {
                let quotaUnit = Units(bytes: Double(int))
                quotaString = "\(usedString) of \(quotaUnit.getReadableUnit())"
            }

            detailLabel.text = quotaString

            // Nextcloud gives a literal representation of the percentage
            // 0.3 = 0.3% in this case
            let correctedProgress = Float(progressFloat / 100)
            progressView.progress = correctedProgress
        default: return
        }
    }
}
