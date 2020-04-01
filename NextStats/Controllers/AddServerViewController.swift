//
//  ViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class AddServerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nicknameField: UITextField!
    @IBOutlet var serverURLField: UITextField!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var infoLabel: UILabel!
    
    var mainViewController: ServerViewController?
    var username: String?
    var appPassword: String?
    var serverURL: String?
    var hasCustomLogo: Bool?
    
    var authAPIURL: URL?
    
    var webViewOpened = false
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - IBActions
    // ----------------------------------------------------------------------------
    
    @IBAction func connectButtonPressed(_ sender: Any) {
        // Check to make sure checkValidURL worked
        guard let url = authAPIURL else { return }
        
        // Initiate the authorization request, and check for logo
        initiateAuthURLRequest(withURL: url)
        checkForLogo(in: url)
        
        activateSpinner()
        
        // Invalidate the url in case user returns and needs to enter again
        authAPIURL = nil
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Server Capture Step 1: Authenticate
    // ----------------------------------------------------------------------------
    
    // 1 - Check the textField for a valid url, if valid enable the connect button
    @objc func checkURLValidity() {
        
        // Reset the authAPIURL if for some reason they had already entered a valid URL
        authAPIURL = nil
        
        // Safely unwrap urlString
        guard var urlString = serverURLField.text else { return }
        
        // Check if url has has prefix, if not add it
        if !urlString.hasPrefix("http") {
            urlString = "https://" + urlString
        }
        
        // Setup and test url
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: urlString)
        
        // Check for nil and return the correct value
        if (result) {
            statusLabel.isHidden = true
            connectButton.isEnabled = true
            authAPIURL = URL(string: urlString)
        } else {
            statusLabel.isHidden = false
            connectButton.isEnabled = false
        }
    }
    
    // 2 - Check if url points to a valid Nextcloud instance
    func initiateAuthURLRequest(withURL url: URL) {
        
        // Append endpoint to url
        let urlWithEndpoint = url.appendingPathComponent(loginEndpoint)
        let urlString = urlWithEndpoint.absoluteString
        print(urlString)
        
        // If using http, switch to https
        let secureUrl = URL(string: urlString.secureURLString())!
        
        var request = URLRequest(url: secureUrl)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, resposne, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.statusLabel.text = "Not a valid host, please check url"
                    self.deactivateSpinner()
                    
                }
            } else {
                if let response = resposne as? HTTPURLResponse {
                    // If server not found, alert user and return
                    if response.statusCode == 404 {
                        DispatchQueue.main.async {
                            self.statusLabel.text = "Nextcloud server not found, please check url"
                            self.deactivateSpinner()
                        }
                        return
                    }

                }
                if let data = data {
                    self.parseJSONFrom(data: data)
                }
            }
        }
        task.resume()
    }
    
    // 3 - Parse the JSON delivered
    func parseJSONFrom(data: Data) {
        let decoder = JSONDecoder()
        
        if let jsonStream = try? decoder.decode(AuthResponse.self, from: data) {
            DispatchQueue.main.async {
                print(jsonStream)
                if let pollURL = URL(string: (jsonStream.poll?.endpoint)!) {
                    if let token = jsonStream.poll?.token {
                        self.loadLoginView(with: jsonStream.login!, pollURL: pollURL, token: token)
                    }
                }
            }
        } else {
            statusLabel.text = "Unable to connect, contact server administrator."
        }
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Server Capture Step 2: Load Login
    // ----------------------------------------------------------------------------
    
    func loadLoginView(with urlString: String, pollURL: URL, token: String) {
        webViewOpened = true
        let vc = LoginWebViewController()
        vc.passedURLString = urlString
        vc.passedPollURL = pollURL
        vc.passedToken = token
        vc.mainViewController = self
        vc.modalPresentationStyle = .automatic
        self.present(vc, animated: true)
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Server Capture Step 3: Capture or Reset
    // ----------------------------------------------------------------------------
    
    func returned() {
        // Called when view is returned to from webView. Test if data was succesfully captured.
        deactivateSpinner()
        
        if webViewOpened {
            if username != nil && appPassword != nil && serverURL != nil {
                statusLabel.text = "success"
                finalizeServer()
            } else {
                statusLabel.text = "authentication canceled"
            }
        }
    }
    
    func finalizeServer() {
        // Assemble captured server data and return server object to Main controller.
        let name: String!
        let friendlyURL = serverURL?.makeFriendlyURL()
        
        if nicknameField.text != nil || nicknameField.text != "" {
            name = nicknameField.text
        } else {
            name = friendlyURL
        }
        
        let server = NextServer(name: name, friendlyURL: friendlyURL!, URLString: serverURL! + statEndpoint, username: username!, password: appPassword!, hasCustomLogo: hasCustomLogo!)
        
        mainViewController?.returned(with: server)
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkForLogo(in url: URL) {
        let urlString = url.absoluteString + logoEndpoint
        let secureUrl = URL(string: urlString.secureURLString())!
        var request = URLRequest(url: secureUrl)
        request.httpMethod = "HEAD"
        
        URLSession(configuration: .default).dataTask(with: request) { (_, response, error) in
            print("LOGO:\(secureUrl)")
            guard error == nil else {
                // server down
                print(error?.localizedDescription)
                self.hasCustomLogo = false
                return
            }
            
            guard(response as? HTTPURLResponse)?.statusCode == 200 else {
                // guard against anything but a 200 OK code
                print(response)
                self.hasCustomLogo = false
                return
            }
            
            // if we made it this far, we good b
            self.hasCustomLogo = true
            return
            
        }.resume()
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - UI Functions
    // ----------------------------------------------------------------------------
    
    func setupUI() {
        // Style the UI
        styleTextField(textField: serverURLField)
        styleTextField(textField: nicknameField)
        connectButton.isEnabled = false
        //connectButton.style()
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
    
    func activateSpinner() {
        spinner.activate()
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
