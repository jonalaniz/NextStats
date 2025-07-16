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

    var image: UIImage? {
        switch self {
        case .storage: return UIImage(systemName: "internaldrive")
        case .memory: return UIImage(systemName: "memorychip")
        case .swap: return UIImage(systemName: "memorychip.fill")
        }
    }
}

class ProgressCell: BaseTableViewCell {
    static let reuseIdentifier = "ProgressCell"

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: ProgressCell.reuseIdentifier)
        setupView()
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
            iconLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor),
            iconLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16),
            iconLabel.trailingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 100),
            iconLabel.bottomAnchor.constraint(
                equalTo: progressView.topAnchor),

            detailLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor),
            detailLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16),
            detailLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16),
            detailLabel.bottomAnchor.constraint(
                equalTo: progressView.topAnchor),

            progressView.heightAnchor.constraint(
                equalToConstant: 4),
            progressView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -16),
            progressView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16),
            progressView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16)
        ])
    }

    private func set(icon: ProgressCellIcon) {
        guard let image = icon.image else { return }
        let string = NSMutableAttributedString()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.theme
        ]

        string.prefixSFSymbol(image, color: .theme)

        let text: String
        switch icon {
        case .storage: text = ""
        case .memory: text = " RAM"
        case .swap: text = " Swap"
        }

        string.append(
            NSAttributedString(
                string: text, attributes: attributes
            )
        )
        iconLabel.attributedText = string
    }

    func configure(free: Int, total: Int, type: ProgressCellIcon) {
        let used = total - free
        let usedString = Units(kilobytes: used).readableUnit
        let totalString = Units(kilobytes: total).readableUnit
        let label = "\(usedString) of \(totalString) Used"

        set(icon: type)
        detailLabel.text = label

        let progress = Float(used) / Float(total)
        progressView.progress = progress
    }

    func configure(title: String, free: Int, total: Int, type: ProgressCellIcon) {
        set(icon: type)
        detailLabel.text = title

        let used = total - free
        let progress = Float(used) / Float(total)
        progressView.progress = progress
    }
}
