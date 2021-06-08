//
//  AddServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class AddServerViewController: UIViewController, UITextFieldDelegate {
    
    weak var coordinator: AddServerCoordinator?
    var serverFormView = ServerFormView()
    var authAPIURL: URL?
    
    override func loadView() {
        view = serverFormView
        
        serverFormView.serverURLField.addTarget(self, action: #selector(checkURLValidity), for: .editingDidEnd)
        serverFormView.connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        
        serverFormView.nicknameField.delegate = self
        serverFormView.serverURLField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
    }
}

extension AddServerViewController {
    @objc func connectButtonPressed(_ sender: Any) {
        // Check to make sure checkValidURL worked
        guard let url = authAPIURL else { return }
        let serverName = serverFormView.nicknameField.text ?? "Server"
        
        // Initiate the authorization request, and check for logo
        coordinator?.requestAuthorization(withURL: url, name: serverName)
        
        serverFormView.activityIndicatior.activate()
        
        // Invalidate the url in case user returns and needs to enter again
        authAPIURL = nil
    }
    
    @objc func cancelPressed() {
        coordinator?.didFinishAdding()
        dismiss(animated: true)
    }
    
    // Detects if URLField has a proper IP Address or URL, formats the string for use with ServerManager
    @objc func checkURLValidity() {
        
        // Reset the authAPIURL if for some reason they had already entered a valid URL
        authAPIURL = nil
        
        // Safely unwrap urlString
        guard let urlString = serverFormView.serverURLField.text?.lowercased() else { return }
        
        // Check for a valid address
        if (urlString.isValidURL()) {
            serverFormView.statusLabel.isHidden = true
            serverFormView.connectButton.isEnabled = true
            
            // Check protocol
            authAPIURL = URL(string: urlString.addDomainPrefix())
        } else if (urlString.isValidIPAddress()) {
            serverFormView.statusLabel.isHidden = true
            serverFormView.connectButton.isEnabled = true
            
            // Check protocol
            authAPIURL = URL(string: urlString.addIPPrefix())
        } else {
            serverFormView.statusLabel.isHidden = false
            serverFormView.connectButton.isEnabled = false
        }
    }
    
    func updateStatusLabel(with text: String) {
        serverFormView.statusLabel.isHidden = false
        serverFormView.statusLabel.text = text
    }
        
    private func setupNavigationController() {
        title = "add_server_title".localized()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
    }
    
    private func deactivateSpinner() {
        serverFormView.activityIndicatior.deactivate()
        serverFormView.statusLabel.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
