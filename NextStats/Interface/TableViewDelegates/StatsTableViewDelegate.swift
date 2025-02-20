//
//  StatsTableViewDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/16/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

class StatsTableViewDelegate: NSObject, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StatsSection(rawValue: indexPath.section)?.rowHeight ?? 0
    }
}
