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
    
    // MARK: - Logo Image Flow
    
    // Check to see if server has custom logo
    func checkForServerLogoImage() {
        if server.hasCustomLogo {
            // Check if server has logo cached already
            if server.imageCached() {
                // If cached, pull the cached image function from server api
                print("image cached")
                spinner.deactivate()
                logoImage.image = server.cachedImage()
            } else {
                print("image not cached, will download")
                spinner.activate()
                downloadImage(to: server.imagePath())
            }
        } else {
            // if no logo, do nothing
            return
        }
    }
    
    // Download and save image
    func downloadImage(to path: String) {
        self.logoImage.isHidden = true
        let url = server.imageURL()
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        // No image found, put default image in place
                        DispatchQueue.main.async {
                            self.logoImage.image = UIImage(named: "nextcloud-server")
                            self.logoImage.isHidden = false
                            self.spinner.deactivate()
                        }                    }
                    print("Poll Status Code: \(response.statusCode)")
                }
                if let data = data {
                    guard let img = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self.logoImage.image = img
                        self.saveImage(img: img, at: path)
                        self.spinner.deactivate()
                        self.logoImage.isHidden = false
                    }
                } else {
                    
                }
            }
        }
        task.resume()
    }
    
    func saveImage(img: UIImage, at path: String) {
        do {
            try img.pngData()?.write(to: URL(string: "file://\(path)")!)
        } catch {
            print("Error, image not saved")
            print(error)
        }
    }

}
