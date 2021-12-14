//
//  ServerLoginAPI.swift
//  NextStats
//
//  Created by Jon Alaniz on 12/11/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

protocol LoginAPI {
    func requestAuthenticationObject(from url: URL, named name: String)
    func checkForCustomImage(at url: URL)
    func setupAuthenitcationObject(with authenitcationObject: AuthenticationObject)
    func createServerFrom(object loginObject: LoginObject)
}
