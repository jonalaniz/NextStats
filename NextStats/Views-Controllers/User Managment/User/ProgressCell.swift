//
//  QuotaCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/26/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import UIKit

class ProgressCell: UITableViewCell {
    var spaceLabel = UILabel()
    var spaceProgressView = UIProgressView()

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    convenience init(quota: Quota) {
        self.init(reuseIdentifier: "QuotaCell")
        setProgress(with: quota)
    }

    convenience init(free: Int, total: Int) {
        self.init(reuseIdentifier: "MemoryCell")
        setProgress(free: free, total: total)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        isUserInteractionEnabled = false
        spaceProgressView.tintColor = .themeColor
        spaceLabel.translatesAutoresizingMaskIntoConstraints = false
        spaceProgressView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spaceLabel)
        contentView.addSubview(spaceProgressView)

        NSLayoutConstraint.activate([
            // Constrain the quotaLabel
            spaceLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            spaceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            spaceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            spaceLabel.bottomAnchor.constraint(equalTo: spaceProgressView.topAnchor),

            // Constrain our storageView
            spaceProgressView.heightAnchor.constraint(equalToConstant: 4),
            spaceProgressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            spaceProgressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            spaceProgressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
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
            quotaString = "\(usedString) of \(quotaUnit.getReadableUnit())"
        }

        spaceLabel.text = quotaString

        // Nextcloud gives a literal representation of the percentage
        // 0.3 = 0.3% in this case
        let correctedProgress = Float(progressFloat / 100)
        spaceProgressView.progress = correctedProgress
    }

    func setProgress(free: Int, total: Int) {
        let used = total - free
        let usedString = Units(kilobytes: Double(used)).getReadableUnit()
        let totalString = Units(kilobytes: Double(total)).getReadableUnit()
        let label = "\(usedString) of \(totalString) Used"

        spaceLabel.text = label

        let progress = Float(used) / Float(total)
        print(progress)
        spaceProgressView.progress = progress
    }
}
