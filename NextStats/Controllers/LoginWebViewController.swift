//
//  LoginWebViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit
import WebKit

// TODO: Observer for server added notification

class LoginWebViewController: UIViewController {
    var webView: WKWebView!
    var passedURLString: String?
    var serverManager: ServerManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let urlString = passedURLString else { return }
        guard let url = URL(string: urlString) else { return }
        
        navigationController?.navigationBar.prefersLargeTitles = false
        self.webView.navigationDelegate = self
        webView.cleanAllCookies()
        webView.load(URLRequest(url: url))
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverAdded), name: .serverDidChange, object: nil)
    }
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // If server credentials were not captured, call the captureServerCredentials with nill
        if serverManager.shouldPoll {
            serverManager.cancelAuthorization()
        }
    }
    
    @objc func serverAdded() {
        navigationController?.dismiss(animated: true)
    }
}

extension LoginWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.title = webView.title
    }
}
