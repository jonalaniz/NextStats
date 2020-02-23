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
    @IBOutlet var bkView: UIView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var server: NextServer?
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func configureCell() {
        // hide the spinner because storyboard doesnt listen when i say to hide it
        spinner.isHidden = true
        
        // style view
        bkView.layer.cornerRadius = 10
        bkView.clipsToBounds = true
        
        // Set cell values
        serverName.text = server?.name
        friendlyURLLabel.text = server?.friendlyURL
        ping()
        checkForServerImageLogo()
    }
    
    // ----------------------------------------------------------------------------
    // MARK: - Ping Server Flow
    // ----------------------------------------------------------------------------
    
    func ping() {
        if let url = URL(string: (server?.friendlyURL.secureURLString())!) {
            var request = URLRequest(url: url)
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
    
    // ----------------------------------------------------------------------------
    // MARK: - Logo Image Flow
    // ----------------------------------------------------------------------------
    
    // 1 - Check to see if server has custom logo
    func checkForServerImageLogo() {
        if server!.hasCustomLogo {
            // Check if server has logo cached already
            if let imgPath = server?.documentsDirectory.appendingPathComponent("\(server!.friendlyURL).png", isDirectory: true).path {
                if imageAlreadyCached(at: imgPath) {
                    print("image downloaded: true")
                    spinner.deactivate()
                    retrieveSavedImage(from: imgPath)
                } else {
                    print("image downloaded: false")
                    spinner.activate()
                    downloadImage(to: imgPath)
                }
            }
        } else {
            // if no logo, do nothing
            return
        }
    }
    
    // 2 - Check to see if image is already cached
    func imageAlreadyCached(at path: String) -> Bool {
        print(path)
        if !FileManager.default.fileExists(atPath: path) {
            print("Image not cached, will download")
            return false
        } else {
            print("Image cached, pulling from cache")
            return true
        }
    }
    
    // 3a - Retrieve cached image
    func retrieveSavedImage(from path: String) {
        logoImage.image = UIImage(contentsOfFile: path)
    }
    
    // 3b - Download and save image
    
    func downloadImage(to path: String) {
        self.logoImage.isHidden = true
        let urlstring = (server?.friendlyURL.secureURLString())! + logoEndpoint
        print("URLSTRING: \(urlstring)")
        let url = URL(string: urlstring)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, resposne, error) in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let response = resposne as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        // No image found, put default image in place
                        DispatchQueue.main.async {
                            self.logoImage.image = UIImage(named: "nextcloud-logo-transparent")
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
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try img.pngData()?.write(to: URL(string: path)!)
            } catch {
                print("Error, image not saved")
            }
        }
    }

}
