//
//  MenuBuilder.swift
//  MenuBuilder
//
//  Created by Jon Alaniz on 7/21/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

extension AppDelegate {
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        // Ensure that the builder is modifying the menu bar system
        guard builder.system == UIMenuSystem.main else { return }

        // Remove unnecissary items
        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)

        let newServerCommand = UIKeyCommand(title: "New Server",
                                            action: #selector(ServerViewController.addServerPressed),
                                            input: "n",
                                            modifierFlags: [.command])
        let newServerMenu = UIMenu(title: "", options: .displayInline, children: [newServerCommand])

        let refreshServersCommand = UIKeyCommand(title: "Refresh Servers",
                                                 action: #selector(ServerViewController.refresh),
                                                 input: "r",
                                                 modifierFlags: [.command])
        let refreshServerCommand = UIKeyCommand(title: "Refresh Server",
                                                action: #selector(StatsViewController.reload),
                                                 input: "r",
                                                modifierFlags: [.command, .shift])
        let refreshServersMenu = UIMenu(title: "",
                                        options: .displayInline,
                                        children: [refreshServersCommand, refreshServerCommand])

        builder.insertChild(refreshServersMenu, atStartOfMenu: .file)
        builder.insertChild(newServerMenu, atStartOfMenu: .file)
    }
}
