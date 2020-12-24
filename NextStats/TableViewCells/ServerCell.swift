//
//  ServerCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/20/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class ServerCell: UITableViewCell {
    var logoImage = UIImageView()
    var serverName = UILabel()
    var friendlyURLLabel = UILabel()
    var statusLabel = UILabel()
    
    var server: NextServer!
    
    func configureCell() {
        constrainUI()
        setupContent()
    }
    
    func constrainUI() {
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        serverName.translatesAutoresizingMaskIntoConstraints = false
        friendlyURLLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(logoImage)
        contentView.addSubview(serverName)
        contentView.addSubview(friendlyURLLabel)
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            logoImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            logoImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            logoImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            logoImage.widthAnchor.constraint(equalToConstant: 80),
            
            serverName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            serverName.heightAnchor.constraint(equalToConstant: 22),
            serverName.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 10),
            serverName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            friendlyURLLabel.heightAnchor.constraint(equalToConstant: 20),
            friendlyURLLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 1),
            friendlyURLLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 10),
            friendlyURLLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            statusLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func setupContent() {
        backgroundColor = .secondarySystemGroupedBackground
        
        logoImage.contentMode = .scaleAspectFit
        
        serverName.font = .preferredFont(forTextStyle: .title2)
        serverName.text = server?.name
        
        friendlyURLLabel.font = .preferredFont(forTextStyle: .headline)
        friendlyURLLabel.text = server?.friendlyURL
        friendlyURLLabel.textColor = .secondaryLabel
        
        statusLabel.font = .preferredFont(forTextStyle: .body)
        
        ping()
        checkForServerLogoImage()
    }
    
    
    
    // MARK: - Ping Server Flow
    func ping() {
        if let url = URL(string: server!.URLString) {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.path = ""
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "HEAD"
            
            URLSession(configuration: .default).dataTask(with: request) { (_, response, error) in
                guard error == nil else {
                    // server down
                    self.setOnlineStatus(to: false)
                    return
                }
                
                guard(response as? HTTPURLResponse)?.statusCode == 200 else {
                    // guard against anything but a 200 OK code
                    self.setOnlineStatus(to: false)
                    return
                }
                
                // if we made it this far, we good b
                self.setOnlineStatus(to: true)
                
            }.resume()
        }
    }
    
    func setOnlineStatus(to online: Bool) {
        DispatchQueue.main.async {
            if online {
                self.statusLabel.textColor = .systemGreen
                self.statusLabel.text = "Online"
            } else {
                self.statusLabel.textColor = .red
                self.statusLabel.text = "Offline"
            }
            self.statusLabel.isHidden = false
            
        }
    }
    
    // MARK: - Check for and load custom logo
    func checkForServerLogoImage() {
        if server.hasCustomLogo {
            // Server should have custom logo
            if server.imageCached() {
                // If cached, pull the cached image function from server api
                print("image found")
                logoImage.image = server.cachedImage()
            } else {
                print("image not found")
                logoImage.image = UIImage(named: "nextcloud-server")
            }
        } else {
            // No custom logo
            logoImage.image = UIImage(named: "nextcloud-server")
            return
        }
    }
}
