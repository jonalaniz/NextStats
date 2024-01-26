//
//  QuotaCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/26/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

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
