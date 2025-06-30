//
//  UserTableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/17/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class UserTableViewDelegate: NSObject, UITableViewDelegate {
    let dataManager: NXUserFormatter

    init(dataManager: NXUserFormatter) {
        self.dataManager = dataManager
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldHide(section: section) ? CGFloat.leastNonzeroMagnitude : 20
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let tableSection = UserSection(rawValue: indexPath.section)
        else { return 44 }

        return tableSection.rowHeight
    }

    func shouldHide(section: Int) -> Bool {
        guard
            let userSection = UserSection(rawValue: section),
            userSection == .mail
        else { return false }

        return dataManager.emailAddresses() == nil
    }
}
