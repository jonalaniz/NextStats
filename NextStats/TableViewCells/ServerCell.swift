//
//  ServerCell.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/20/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import UIKit

class ServerCell: UITableViewCell {
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var serverName: UILabel!
    @IBOutlet var friendlyURLLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var server: NextServer!
    
    func configureCell() {
        // hide the spinner because storyboard doesnt listen when i say to hide it
        spinner.isHidden = true
        
        // Set cell values
        serverName.text = server?.name
        friendlyURLLabel.text = server?.friendlyURL
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
