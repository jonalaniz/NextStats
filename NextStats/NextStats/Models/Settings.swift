//
//  Settings.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/11/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

/// Settings struct from Nextcloud server
struct Settings: Codable {
    let name: String?
    let shortName: String?
    let startURL: String?
    let themeColor: String?
    let backgroundColor: String?
    let description: String?
    let display: String?
    let icons: [Icon]?

    enum CodingKeys: String, CodingKey {
        case name, description, display, icons
        case shortName = "short_name"
        case startURL = "start_url"
        case themeColor = "theme_color"
        case backgroundColor = "background_color"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.shortName = try container.decode(String.self, forKey: .shortName)
        self.startURL = try container.decode(String.self, forKey: .startURL)
        self.themeColor = try container.decode(String.self, forKey: .themeColor)
        self.backgroundColor = try container.decode(String.self, forKey: .backgroundColor)
        self.description = try container.decode(String.self, forKey: .description)
        self.display = try container.decode(String.self, forKey: .display)
        self.icons = try container.decode([Icon].self, forKey: .icons)
    }
}

struct Icon: Codable {
    let src: String
    let type: String
    let sizes: String
}

let jsonString = """
{
  "name": "Nextcloud",
  "short_name": "Nextcloud",
  "start_url": "https://cloud.jonalaniz.com",
  "theme_color": "#0082c9",
  "background_color": "#0082c9",
  "description": "a safe home for all your data",
  "icons": [
    {
      "src": "/index.php/apps/theming/icon/settings?v=2",
      "type": "image/png",
      "sizes": "512x512"
    },
    {
      "src": "/index.php/apps/theming/favicon/settings?v=2",
      "type": "image/svg+xml",
      "sizes": "16x16"
    }
  ],
  "display": "standalone"
}
"""
