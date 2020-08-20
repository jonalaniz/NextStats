//
//  ViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

protocol RefreshServerTableViewDelegate: class {
    func refreshTableView()
}

class AddServerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nicknameField: UITextField!
    @IBOutlet var serverURLField: UITextField!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var infoLabel: UILabel!
    
    weak var delegate: RefreshServerTableViewDelegate?
    
    var serverManager: ServerManager!
    var username: String?
    var appPassword: String?
    var serverURL: String?
    var hasCustomLogo: Bool?
    var authAPIURL: URL?
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverManager.delegate = self
    }
    
    @IBAction func connectButtonPressed(_ sender: Any) {
        // Check to make sure checkValidURL worked
        guard let url = authAPIURL else { return }
        
        // Initiate the authorization request, and check for logo
        serverManager.requestAuthorizationURL(withURL: url)
        checkForLogo(in: url)
        
        spinner.activate()
        
        // Invalidate the url in case user returns and needs to enter again
        authAPIURL = nil
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // 1 - Check the textField for a valid url, if valid enable the connect button
    @objc func checkURLValidity() {
        
        // Reset the authAPIURL if for some reason they had already entered a valid URL
        authAPIURL = nil
        
        // Safely unwrap urlString
        guard let urlString = serverURLField.text?.lowercased() else { return }
        
        // Check for a valid address
        if (urlString.isValidURL()) {
            statusLabel.isHidden = true
            connectButton.isEnabled = true
            
            // Check protocol
            authAPIURL = URL(string: urlString.addDomainPrefix())
        } else if (urlString.isValidIPAddress()) {
            statusLabel.isHidden = true
            connectButton.isEnabled = true
            
            // Check protocol
            authAPIURL = URL(string: urlString.addIPPrefix())
        } else {
            statusLabel.isHidden = false
            connectButton.isEnabled = false
        }
    }
    
    func loadLoginView(with urlString: String, pollURL: URL, token: String) {
        let vc = LoginWebViewController()
        vc.passedURLString = urlString
        vc.passedPollURL = pollURL
        vc.passedToken = token
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Server Capture Step 3: Check for Logo
    // ----------------------------------------------------------------------------

    func checkForLogo(in url: URL) {
        let urlWithEndpoint = url.appendingPathComponent(logoEndpoint)
        var request = URLRequest(url: urlWithEndpoint)
        request.httpMethod = "HEAD"
        
        URLSession(configuration: .default).dataTask(with: request) { (_, response, error) in
            print("LOGO:\(urlWithEndpoint)")
            guard error == nil else {
                // server down
                print(error?.localizedDescription)
                self.hasCustomLogo = false
                return
            }
            
            guard(response as? HTTPURLResponse)?.statusCode == 200 else {
                // guard against anything but a 200 OK code
                print("Response: \(response)")
                self.hasCustomLogo = false
                return
            }
            
            // if we made it this far, we good b
            self.hasCustomLogo = true
            return
            
        }.resume()
    }
    
    // MARK: - UI
    
    func setupUI() {
        // Style the UI
        styleTextField(textField: nicknameField)
        nicknameField.attributedPlaceholder = NSAttributedString(string: "MyServer", attributes: [NSAttributedString.Key.foregroundColor: placeholderTextColor])
        styleTextField(textField: serverURLField)
        serverURLField.attributedPlaceholder = NSAttributedString(string: "https://cloud.example.com", attributes: [NSAttributedString.Key.foregroundColor: placeholderTextColor])

        connectButton.isEnabled = false
        spinner.isHidden = true
        
        // Setup the targets
        serverURLField.addTarget(self, action: #selector(checkURLValidity), for: UIControl.Event.editingDidEnd)
    }
    
    func styleTextField(textField: UITextField) {
        // Style the textFields
        textField.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
        textField.borderStyle = .none
        textField.layoutIfNeeded()
    }
    
    func deactivateSpinner() {
        spinner.deactivate()
        statusLabel.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension AddServerViewController: CaptureServerCredentialsDelegate {
    func captureServerCredentials(with credentials: ServerAuthenticationInfo?) {
        if let serverURL = credentials?.server, let username = credentials?.loginName, let password = credentials?.appPassword {
            statusLabel.text = "success"
            var name: String!
            let URLString = serverURL + statEndpoint
            let friendlyURL = serverURL.makeFriendlyURL()
            
            if nicknameField.text != nil && nicknameField.text != "" {
                name = nicknameField.text
            } else {
                name = serverURL
            }
            
            let server = NextServer(name: name, friendlyURL: friendlyURL, URLString: URLString, username: username, password: password, hasCustomLogo: hasCustomLogo!)
            serverManager.servers.append(server)
            self.delegate?.refreshTableView()
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            deactivateSpinner()
            statusLabel.text = "authentication canceled"
        }
    }
}

extension AddServerViewController: ServerManagerDelegate {
    func authorizationDataRecieved(loginURL: String, pollURL: URL, token: String) {
        loadLoginView(with: loginURL, pollURL: pollURL, token: token)
    }
    
    func failedToGetAuthorizationURL(withError error: String) {
        statusLabel.text = error
        deactivateSpinner()
    }
}
