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
    
    var servers: NextServers!
    var username: String?
    var appPassword: String?
    var serverURL: String?
    var hasCustomLogo: Bool?
    var authAPIURL: URL?
    
    let placeholderTextColor = UIColor(red: 149/255, green: 152/255, blue: 167/255, alpha: 0.4)
        
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
        
        spinner.activate()
        
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
        guard let urlString = serverURLField.text?.lowercased() else { return }
        
        // Setup and test url
        let urlRegEx = "^(https://|http://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let ipRegEx = #"(^192\.168\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])$)|(^172\.([1][6-9]|[2][0-9]|[3][0-1])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])$)|(^10\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])$)"#
        
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let ipTest = NSPredicate(format:"SELF MATCHES %@", ipRegEx)
        
        let isURL = urlTest.evaluate(with: urlString)
        let isIPAddress = ipTest.evaluate(with: urlString)
        
        // Check for a valid address
        if (isURL) {
            statusLabel.isHidden = true
            connectButton.isEnabled = true
            
            // Check protocol
            authAPIURL = URL(string: urlString.addDomainPrefix())
        } else if (isIPAddress) {
            statusLabel.isHidden = true
            connectButton.isEnabled = true
            
            // Check protocol
            authAPIURL = URL(string: urlString.addIPPrefix())
        } else {
            statusLabel.isHidden = false
            connectButton.isEnabled = false
        }
    }
    
    // 2 - Check if url points to a valid Nextcloud instance
    func initiateAuthURLRequest(withURL url: URL) {
        
        // Append endpoint to url
        let urlWithEndpoint = url.appendingPathComponent(loginEndpoint)
        
        var request = URLRequest(url: urlWithEndpoint)
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
            DispatchQueue.main.async {
                self.statusLabel.text = "Unable to connect, contact server administrator."
            }
        }
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Server Capture Step 2: Load LoginViewController
    // ----------------------------------------------------------------------------
    
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
    
    // ----------------------------------------------------------------------------
    // MARK: - UI Functions
    // ----------------------------------------------------------------------------
    
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
            servers.instances.append(server)
            self.delegate?.refreshTableView()
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            deactivateSpinner()
            statusLabel.text = "authentication canceled"
        }
    }
}
