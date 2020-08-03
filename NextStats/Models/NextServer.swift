//
//  ServerCellModel.swift
//  NextStats
//
//  Created by Jon Alaniz on 8/2/20.
//  Copyright © 2020 Jon Alaniz. All rights reserved.
//

import Foundation
import UIKit

struct NextServer: Codable {
    let name: String
    let friendlyURL: String
    let URLString: String
    let username: String
    let password: String
    let hasCustomLogo: Bool
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func imageURL() -> URL {
        let url = URL(string: URLString)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = ""
        
        return (components.url?.appendingPathComponent(logoEndpoint))!
    }
    
    func imagePath() -> String {
        return documentsDirectory.appendingPathComponent("\(friendlyURL).png", isDirectory: true).path
    }
    
    func imageCached() -> Bool {
        let path = imagePath()
        if FileManager.default.fileExists(atPath: path) {
            print(FileManager.default.fileExists(atPath: path))
            return true
        } else {
            print(FileManager.default.fileExists(atPath: path))
            return false
        }
    }
    
    func cachedImage() -> UIImage {
        return UIImage(contentsOfFile: imagePath())!
    }
}
