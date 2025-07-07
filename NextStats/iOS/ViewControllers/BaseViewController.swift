//
//  BaseViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 2/5/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import UIKit

/// A base view controller that provides a common background layout for its subclasses.
///
/// `BaseViewController` ensures that all inheriting view controllers have a consistent
/// background appearance with a semi-transparent background image.
class BaseViewController: UIViewController {

    /// A background image view that is applied to all subclasses.
    /// This provides a consistent visual theme across the app.
    private let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background")
        imageView.layer.opacity = 0.5
        return imageView
    }()

    /// Called after the view controller has loaded its view hierarchy into memory.
    ///
    /// This method ensures that the view setup and layout constraints are applied
    /// before the view appears on screen.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        constrainView()
    }

    /// Sets up the view hierarchy and properties.
    ///
    /// This method is designed to be overridden by subclasses that need to add additional
    /// UI elements while keeping the base background setup.
    func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
    }

    /// Applies layout constraints to position the background view correctly.
    ///
    /// This ensures the background image fully covers the view, maintaining consistency
    /// across all screens.
    func constrainView() {
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
