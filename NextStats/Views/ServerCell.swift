//
//  ServerCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/20/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class ServerCell: UITableViewCell {
    // MARK: Properties
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
    
    var server: NextServer!
    let networkController = NetworkController.shared
    
}

extension ServerCell {
    func setup() {
        contentView.addSubview(logoImageView)
        contentView.addSubview(serverNameLabel)
        contentView.addSubview(friendlyURLLabel)
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            logoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            logoImageView.widthAnchor.constraint(equalToConstant: 78),
            
            serverNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            serverNameLabel.heightAnchor.constraint(equalToConstant: 22),
            serverNameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
            serverNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            friendlyURLLabel.heightAnchor.constraint(equalToConstant: 20),
            friendlyURLLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 1),
            friendlyURLLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
            friendlyURLLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            statusLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
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
        
        networkController.fetchData(from: components!.url!) { (result: Result<Data, FetchError>) in
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
        }
    }
    
    // MARK: Check for and load custom logo
    private func checkForServerLogoImage() {
        if server.hasCustomLogo {
            // Server should have custom logo
            if server.imageCached() {
                // If cached, pull the cached image function from server api
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
