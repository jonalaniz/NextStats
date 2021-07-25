//
//  WebViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import UIKit
import WebKit

/// Simple view that has a full-screen WKWebView that displays web page title in NavigationBar
class WebViewController: UIViewController {
    weak var coordinator: AddServerCoordinator?
    var webView: WKWebView!
    var passedURLString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false

        guard let url = URL(string: passedURLString) else { return }

        self.webView.navigationDelegate = self
        webView.cleanAllCookies()
        webView.load(URLRequest(url: url))
    }
}

extension WebViewController: WKNavigationDelegate {
    @objc func serverAdded() {
        navigationController?.dismiss(animated: true)
    }

    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.title = webView.title
    }
}
