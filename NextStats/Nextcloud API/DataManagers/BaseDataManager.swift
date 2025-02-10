//
//  BaseDataManager.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

class BaseDataManager: NSObject {
    /// A shared instance of `Configurator` that handles app and authentication specific configurations.
    let serverManager: NXServerManager

    /// A shared instance of `FreeScoutService` that manages network interactions with FreeScout.
    let service: NextcloudService

    /// A weak reference to the delegate responsible for handling data-related events.
    weak var delegate: DataManagerDelegate?

    /// Initializes the `BaseDataManager` with default or custom dependencies.
    ///
    /// - Parameters:
    ///   - serverManager: The manager responsible for servers and their configurations. Defaults to
    ///   `NXServerManager.shared`.
    ///   - service: The service responsible for handling network requests. Defaults to `NextcloudService.shared`.
    init(serverManager: NXServerManager = NXServerManager.shared, service: NextcloudService = NextcloudService.shared) {
        self.serverManager = serverManager
        self.service = service
    }

    /// Notifies the delegate that the data has been updated.
    ///
    /// This method must be called on the main thread using the `@MainActor` attribute to ensure UI updates
    /// are safe and synchronized.
    @MainActor
    func notifyDataUpdated() {
        self.delegate?.dataUpdated()
    }
}
