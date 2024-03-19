//
//  Endpoints.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/19/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

enum Endpoints: String {
    case appPassword = "/ocs/v2.php/core/apppassword"
    case login = "/index.php/login/v2"
    case logo = "/index.php/apps/theming/image/logo"
    case info = "/ocs/v2.php/apps/serverinfo/api/v1/info"
    case users = "/ocs/v1.php/cloud/users"
    case user = "/ocs/v1.php/cloud/users/"
    case settings = "/index.php/apps/theming/manifest/settings"
}
