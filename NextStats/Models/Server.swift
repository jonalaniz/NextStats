//
//  Server.swift
//  NextStats
//
//  Created by Jon Alaniz on 8/2/20.
//  Copyright © 2020 Jon Alaniz
//

import Foundation
import UIKit

/// Server object used to store Nextcloud server information and credentials
struct NextServer: Codable {
    let name: String
    let friendlyURL: String
    let URLString: String
    let username: String
    let password: String
    var hasCustomLogo: Bool = false

    func authenticationString() -> String {
        let credentials = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        let authenticationString = "Basic \(credentials)"

        return authenticationString
    }

    func cachedImage() -> UIImage {
        return UIImage(contentsOfFile: imagePath())!
    }

    func imageURL() -> URL {
        let url = URL(string: URLString)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = Paths.logoEndpoint

        return components.url!
    }

    func imagePath() -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        return documentsDirectory.appendingPathComponent("\(friendlyURL).png", isDirectory: true).path
    }

    func imageCached() -> Bool {
        let path = imagePath()
        if FileManager.default.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
    }

    mutating func setCustomLogo() {
        hasCustomLogo = true
    }
}
