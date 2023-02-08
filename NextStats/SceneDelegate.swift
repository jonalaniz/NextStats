//
//  SceneDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz
//

import UIKit

// swiftlint:disable all
class SceneDelegate: UIResponder, UIWindowSceneDelegate, UISplitViewControllerDelegate {
    var coordinator: MainCoordinator?
    var window: UIWindow?
    var toolbarDelegate = ToolbarDelegate()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { fatalError() }
        window = UIWindow(windowScene: windowScene)

        configureSplitViewController()

        #if targetEnvironment(macCatalyst)
        // Set min and max windows size
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
            let minimumSize = CGSize(width: 800, height: 600)
            let maximumSize = CGSize(width: 1024, height: 768)

            windowScene.sizeRestrictions?.minimumSize = minimumSize
            windowScene.sizeRestrictions?.maximumSize = maximumSize
        }

        // Create toolbar
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly

        // Remove titlebar and set toolbar
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .automatic
        }
        #endif
    }

    private func configureSplitViewController() {
        guard let window = window else { fatalError() }

        // Initialize a SplitViewController and Coordinator
        let splitViewController = UISplitViewController()
        coordinator = MainCoordinator(splitViewController: splitViewController)
        coordinator?.start()

        // Setup our SplitViewController
        splitViewController.preferredDisplayMode = UISplitViewController.DisplayMode.oneBesideSecondary
        splitViewController.primaryBackgroundStyle = .sidebar
        splitViewController.delegate = self

        // Set the window to the SplitViewController
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
        window.tintColor = .themeColor
    }

    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }

}
