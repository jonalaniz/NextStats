//
//  ServerCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/20/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class ServerCell: UITableViewCell {
    var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        
        return logoImageView
    }()
    
    var serverNameLabel: UILabel = {
        let serverNameLabel = UILabel()
        serverNameLabel.translatesAutoresizingMaskIntoConstraints = false
        serverNameLabel.font = .preferredFont(forTextStyle: .title2)
        
        return serverNameLabel
    }()
    
    var friendlyURLLabel: UILabel = {
        let friendlyURLLabel = UILabel()
        friendlyURLLabel.translatesAutoresizingMaskIntoConstraints = false
        friendlyURLLabel.font = .preferredFont(forTextStyle: .body)
        friendlyURLLabel.textColor = .secondaryLabel
        
        return friendlyURLLabel
    }()
    
    var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .preferredFont(forTextStyle: .headline)
        
        return statusLabel
    }()
    
    var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 2
        
        return stackView
    }()
    
    var server: NextServer!
    let networkController = NetworkController.shared
    
}

extension ServerCell {
    func setup() {
        contentView.addSubview(logoImageView)
        contentView.addSubview(verticalStackView)
        
        verticalStackView.addArrangedSubview(serverNameLabel)
        verticalStackView.addArrangedSubview(friendlyURLLabel)
        verticalStackView.addArrangedSubview(statusLabel)
        
        logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 78).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 78).isActive = true
        
        verticalStackView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor).isActive = true
        
        if traitCollection.userInterfaceStyle == .light {
            backgroundColor = .quaternarySystemFill
        }
                
        serverNameLabel.text = server?.name
        friendlyURLLabel.text = server?.friendlyURL
                
        pingServer()
        checkForServerLogoImage()
    }
    
    private func pingServer() {
        let longURL = URL(string: server.URLString)!
        var components = URLComponents(url: longURL, resolvingAgainstBaseURL: false)
        components?.path = ""
        let request = URLRequest(url: components!.url!)
        
        networkController.fetchData(with: request) { (result: Result<Data, FetchError>) in
            switch result {
            case .failure(let error):
                print(error)
                self.setOnlineStatus(to: false)
            case .success(_):
                self.setOnlineStatus(to: true)
            }
        }
    }
    
    private func setOnlineStatus(to online: Bool) {
        DispatchQueue.main.async {
            if online {
                self.statusLabel.textColor = .systemGreen
                self.statusLabel.text = "Online"
            } else {
                self.statusLabel.textColor = .red
                self.statusLabel.text = "Unreachable"
            }
            
            self.statusLabel.layer.opacity = 0.8
            self.statusLabel.isHidden = false
            
            UIView.animate(withDuration: 0.4) {
                self.verticalStackView.layoutIfNeeded()
            }
        }
    }
    
    // TODO: Make server logo something that is checked for on each connection, then grab the image.
    private func checkForServerLogoImage() {
        if server.hasCustomLogo {
            if server.imageCached() {
                // Check server cached logo
                print("image found")
                logoImageView.image = server.cachedImage()
            } else {
                print("image not found")
                logoImageView.image = UIImage(named: "nextcloud-server")
            }
        } else {
            // No custom logo
            logoImageView.image = UIImage(named: "nextcloud-server")
            return
        }
    }
}
