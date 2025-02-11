//
//  Endpoints.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/19/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

enum Endpoint: String {
    case appPassword = "/ocs/v2.php/core/apppassword"
    case groups = "/ocs/v1.php/cloud/groups"
    case info = "/ocs/v2.php/apps/serverinfo/api/v1/info"
    case login = "/index.php/login/v2"
    case logo = "index.php/apps/theming/image/logo"
    case settings = "/index.php/apps/theming/manifest/settings"
    case user = "/ocs/v1.php/cloud/users"
    case wipeCheck = "/index.php/core/wipe/check"
    case wipeSuccess = "/index.php/core/wipe/success"
}
