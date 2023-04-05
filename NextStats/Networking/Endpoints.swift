//
//  Endpoints.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/19/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

enum Endpoints: String {
    case appPassword = "/ocs/v2.php/core/apppassword"
    case loginEndpoint = "/index.php/login/v2"
    case logoEndpoint = "/index.php/apps/theming/image/logo"
    case statEndpoint = "/ocs/v2.php/apps/serverinfo/api/v1/info"
    case usersEndpoint = "/ocs/v1.php/cloud/users"
    case userEndpoint = "/ocs/v1.php/cloud/users/"
}
