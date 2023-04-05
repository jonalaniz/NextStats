//
//  LoginObject.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/11/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

struct LoginObject: Decodable {
    let server: String?
    let loginName: String?
    let appPassword: String?
}
