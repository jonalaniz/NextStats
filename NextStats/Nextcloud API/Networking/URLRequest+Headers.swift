//
//  URLRequest+Headers.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation
import UIKit

extension URLRequest {
    mutating func addHeaders(from headers: [String: String]?) {
        if let headers = headers {
            headers.forEach { self.addValue($0.value, forHTTPHeaderField: $0.key) }
        }
    }

    mutating func setUserAgent() {
        let osName: String

        switch UIDevice.current.userInterfaceIdiom {
        case .phone: osName = "iOS"
        case .pad: osName = "iPadOS"
        case .tv: osName = "tvOS"
        case .carPlay: osName = "carPlay"
        case .mac: osName = "macOS"
        case .vision: osName = "visionOS"
        default: osName = "¯\\_(ツ)_/¯"
        }

        self.setValue(Header.userAgent(osName).value(),
                      forHTTPHeaderField: Header.userAgent(osName).key())
    }
}
