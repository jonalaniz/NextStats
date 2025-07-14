//
//  NXUserFactoryDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 3/28/24.
//  Copyright © 2024 Jon Alaniz. All rights reserved.
//

import Foundation

protocol NXUserFactoryDelegate: AnyObject {
    func stateDidChange(_ state: NXUserFactoryState)
    func error(_ error: NXUserFactoryErrorType)
}

enum NXUserFactoryErrorType {
    case application(_ error: NXUserFactoryError)
    case network(APIManagerError)
    case server(code: Int, status: String, message: String)
}

enum NXUserFactoryError: Error {
    case unableToEncodeData
    case missingRequiredFields(RequiredField)
}

enum RequiredField {
    case userId
    case email
    case password
}

enum NXUserFactoryState {
    case userCreated(data: Data)
    case sucess
    case readyToBuild
}
