//
//  LoginWebViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/11/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit
import WebKit

protocol CaptureServerCredentialsDelegate: class {
    func captureServerCredentials(with credentials: ServerAuthenticationInfo?)
}

class LoginWebViewController: UIViewController {
    var webView: WKWebView!
    var passedURLString: String?
    var passedPollURL: URL?
    var passedToken: String?
    var shouldContinuePolling = true
    
    weak var delegate: CaptureServerCredentialsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let urlString = passedURLString else { return }
        guard let url = URL(string: urlString) else { return }
        webView.cleanAllCookies()
        webView.load(URLRequest(url: url))
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.pollForCredentials()
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // If server credentials were not captured, call the captureServerCredentials with nill
        if shouldContinuePolling {
            self.delegate?.captureServerCredentials(with: nil)
            shouldContinuePolling = false
        }
    }
    
    func pollForCredentials() {
        // test credentials passed from past view controller
        guard let url = passedPollURL else { return }
        guard let token = passedToken else { return }
        
        // attach token and setup request
        let tokenPrefix = "token="
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.httpBody = (tokenPrefix + token).data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        if self.shouldContinuePolling {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.pollForCredentials()
                            }
                        }
                    }
                    print("Poll Status Code: \(response.statusCode)")
                }
                if let data = data {
                    self.decodeCredentialsFrom(json: data)
                }
            }
        }
        task.resume()
    }
    
    func decodeCredentialsFrom(json: Data) {
        let decoder = JSONDecoder()
        if let jsonStream = try? decoder.decode(ServerAuthenticationInfo.self, from: json) {
            DispatchQueue.main.async {
                print(jsonStream)
                self.delegate?.captureServerCredentials(with: jsonStream)
                self.shouldContinuePolling = false
                self.dismiss(animated: true)
            }
        }
    }
}
