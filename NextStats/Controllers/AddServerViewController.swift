//
//  AddServerViewController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/10/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class AddServerViewController: UIViewController, UITextFieldDelegate {
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 12
        
        return stackView
    }()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Replace with NSLocalizedString
        label.textColor = UIColor.secondaryLabel
        label.text = "server_nickname".localized()
        
        return label
    }()
    
    let nicknameField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.backgroundColor = .systemFill
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: "MyServer", attributes: [NSAttributedString.Key.foregroundColor: UIColor.quaternaryLabel])
        
        return textField
    }()
    
    let serverURLLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Replace with NSLocalizedString
        label.textColor = UIColor.secondaryLabel
        label.text = "server_url".localized()
        
        return label
    }()
    
    let serverURLField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(checkURLValidity), for: .editingDidEnd)
        textField.textContentType = .URL
        textField.autocapitalizationType = .none
        textField.keyboardType = .URL
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.backgroundColor = .systemFill
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.attributedPlaceholder = NSAttributedString(string: "https://cloud.example.com", attributes: [NSAttributedString.Key.foregroundColor: UIColor.quaternaryLabel])
        
        return textField
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        // Replace with NSLocalized String
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = "info_label".localized()
        
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        // Replace with NSLocaliszedString
        label.textColor = UIColor(red: 255/255, green: 42/255, blue: 85/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.text = "status_label".localized()
        
        return label
    }()
    
    let activityIndicatior: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .medium
        indicator.color = .white
        indicator.isHidden = true
        
        return indicator
    }()
    
    let paddingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 142 / 255, green: 154 / 255, blue: 255 / 255, alpha: 1.0)
        button.layer.cornerRadius = 10
        // Replace with NSLocalized String
        button.setTitle("connect".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.isEnabled = false
        return button
    }()
    
    var serverManager: ServerManager!
    var serverURL: String?
    var authAPIURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        serverManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(authenticationCanceled), name: .authenticationCanceled, object: nil)
    }
}

extension AddServerViewController {
    
    @objc func connectButtonPressed(_ sender: Any) {
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
        let vc = WebViewController()
        vc.serverManager = serverManager
        vc.passedURLString = urlString
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UI
    
    func setupView() {
        // Setup View
        view.backgroundColor = .systemBackground
        
        // Setup Top Bar
        title = "add_server_title".localized()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        
        // Style the UI
        styleTextField(textField: nicknameField)
        styleTextField(textField: serverURLField)
        
        // Arrange subviews
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(nicknameField)
        stackView.addArrangedSubview(serverURLLabel)
        stackView.addArrangedSubview(serverURLField)
        stackView.addArrangedSubview(statusLabel)
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(activityIndicatior)
        stackView.addArrangedSubview(paddingView)
        stackView.addArrangedSubview(connectButton)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            nicknameField.heightAnchor.constraint(equalToConstant: 44),
            serverURLField.heightAnchor.constraint(equalToConstant: 44),
            connectButton.heightAnchor.constraint(equalToConstant: 44),
            paddingView.heightAnchor.constraint(equalToConstant: 10),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    func styleTextField(textField: UITextField) {
        // Style the textFields
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))

        textField.delegate = self
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
        textField.borderStyle = .none
        textField.layoutIfNeeded()
        textField.layer.cornerRadius = 10
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
