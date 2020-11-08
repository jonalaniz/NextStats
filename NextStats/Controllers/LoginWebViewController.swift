//
//  LoginWebViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit
import WebKit

/**
 Sets the view to a WKWebView and loads the login page for the user.
 LoginWebViewController also notifies if user canceles authenitcaiton.
 */
class LoginWebViewController: UIViewController {
    var webView: WKWebView!
    var passedURLString: String!
    var serverManager: ServerManager!
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        
        guard let url = URL(string: passedURLString) else { return }
        
        self.webView.navigationDelegate = self
        webView.cleanAllCookies()
        webView.load(URLRequest(url: url))
        
        NotificationCenter.default.addObserver(self, selector: #selector(serverAdded), name: .serverDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // If server credentials were not captured, cancel authorization and post a notification
        if serverManager.shouldPoll {
            serverManager.cancelAuthorization()
            NotificationCenter.default.post(name: .authenticationCanceled, object: nil)
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
