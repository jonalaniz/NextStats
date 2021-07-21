//
//  ToolbarDelegate.swift
//  ToolbarDelegate
//
//  Created by Jon Alaniz on 7/20/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

class StatisticsToolbarDelegate: NSObject {}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let refresh = NSToolbarItem.Identifier("com.jonalaniz.nextstats.refresh")
    static let openInSafari = NSToolbarItem.Identifier("com.jonalaniz.nextstats.openInSafari")
}

extension StatisticsToolbarDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .toggleSidebar,
            .flexibleSpace,
            .refresh,
            .openInSafari
        ]

        return identifiers
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        var toolbarItem: NSToolbarItem?

        switch itemIdentifier {
        case .refresh:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "arrow.clockwise")
            item.label = "Refresh Server"
            item.action = #selector(StatsViewController.reload)
            item.target = nil
            toolbarItem = item
        case .openInSafari:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "safari.fill")
            item.label = "Open in Safari"
            item.action = #selector(StatsViewController.openInSafari)
            item.target = nil
            toolbarItem = item
        default:
            toolbarItem = nil
        }

        return toolbarItem
    }

}
#endif
