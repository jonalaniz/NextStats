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
 Reusable WKWebView controller.
 
 Passing in a ServerManager allows for capturing of server credentials:
 Sets the view to a WKWebView and loads the login page for the user.
 LoginWebViewController also notifies if user canceles authenitcaiton.
 */
class WebViewController: UIViewController {
    var webView: WKWebView!
    var passedURLString: String!
    var serverManager: ServerManager?
    
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
        // Check if manager was passed, then check if server credentials were not captured, cancel authorization and post a notification
        if let manager = serverManager {
            if manager.shouldPoll {
                manager.cancelAuthorization()
                NotificationCenter.default.post(name: .authenticationCanceled, object: nil)
            }
        }
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
