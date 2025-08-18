//
//  ToolbarDelegate.swift
//  ToolbarDelegate
//
//  Created by Jon Alaniz on 7/20/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit

class ToolbarDelegate: NSObject {
    var coordinator: Coordinator?
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let addServer = NSToolbarItem.Identifier("com.jonalaniz.nextstats.addServer")
    static let menu = NSToolbarItem.Identifier("com.jonalaniz.nextstats.menu")
}

extension ToolbarDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .flexibleSpace,
            .addServer,
            .primarySidebarTrackingSeparatorItemIdentifier,
            .menu
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
        case .addServer:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = Symbols.plus
            item.label = "Add Server"
            item.action = #selector(MainCoordinator.addServerClicked)
            item.target = coordinator
            toolbarItem = item
        case .menu:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = Symbols.ellipsisCircle.image
            item.label = "Server Menu"
            item.action = #selector(MainCoordinator.menuClicked)
            item.target = coordinator
            toolbarItem = item
        default:
            toolbarItem = nil
        }

        return toolbarItem
    }

//    func buildServerMenu() -> UIMenu {
//        let renameServer = UICommand(title: "Rename", action: #selector(StatsViewController.showRenameSheet))
//        let delete = UICommand(title: "Delete", action: #selector(StatsViewController.delete(action:)))
//        let menu = UIMenu(title: "", options: .displayInline, children: [renameServer, delete])
//
//        return menu
//    }

}
#endif
