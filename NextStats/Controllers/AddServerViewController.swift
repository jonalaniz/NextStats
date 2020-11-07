//
//  AddServerViewController.swift
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
    @IBOutlet var activityIndicatior: UIActivityIndicatorView!
    @IBOutlet var infoLabel: UILabel!

    var serverManager: ServerManager!
    var serverURL: String?
    var authAPIURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        serverManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationCanceled), name: .authenticationCanceled, object: nil)
    }
    
    @IBAction func connectButtonPressed(_ sender: Any) {
        // Check to make sure checkValidURL worked
        guard let url = authAPIURL else { return }
        let serverName = nicknameField.text ?? "Server"
        
        // Initiate the authorization request, and check for logo
        serverManager.requestAuthorizationURL(withURL: url, withName: serverName)
        
        activityIndicatior.activate()
        
        // Invalidate the url in case user returns and needs to enter again
        authAPIURL = nil
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true)
    }
    
    @objc func authenticationCanceled() {
        deactivateSpinner()
        statusLabel.text = "Authentication canceled"
    }
    
    /**
     Detects if URLField has a proper IP Address or URL, formats the string for use with ServerManager
     */
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
    
    func loadLoginView(with urlString: String) {
        let vc = LoginWebViewController()
        vc.serverManager = serverManager
        vc.passedURLString = urlString
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UI
    
    func setupUI() {
        // Setup Top Bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        
        // Style the UI
        styleTextField(textField: nicknameField)
        nicknameField.attributedPlaceholder = NSAttributedString(string: "MyServer", attributes: [NSAttributedString.Key.foregroundColor: placeholderTextColor])
        
        styleTextField(textField: serverURLField)
        serverURLField.attributedPlaceholder = NSAttributedString(string: "https://cloud.example.com", attributes: [NSAttributedString.Key.foregroundColor: placeholderTextColor])

        connectButton.isEnabled = false
        activityIndicatior.isHidden = true
        
        // Add url checker to serverURLField
        serverURLField.addTarget(self, action: #selector(checkURLValidity), for: UIControl.Event.editingDidEnd)
    }
    
    func styleTextField(textField: UITextField) {
        // Style the textFields
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))

        textField.delegate = self
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
        textField.borderStyle = .none
        textField.layoutIfNeeded()
    }
    
    func deactivateSpinner() {
        activityIndicatior.deactivate()
        statusLabel.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension AddServerViewController: ServerManagerAuthenticationDelegate {
    func serverCredentialsCaptured() {
        // Do nothing, the LoginWebViewController now dismisses the parent NavigationView
    }
    
    func authorizationDataRecieved(loginURL: String) {
        loadLoginView(with: loginURL)
    }
    
    func failedToGetAuthorizationURL(withError error: ServerManagerAuthenticationError) {
        statusLabel.text = error.description
        deactivateSpinner()
    }
    
    func serverAdded() {
        deactivateSpinner()
        statusLabel.text = "success"
        self.dismiss(animated: true)
    }
}
