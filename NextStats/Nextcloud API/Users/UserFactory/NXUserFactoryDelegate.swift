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
    case app(_ error: NXUserFactoryError)
    case networking(NetworkError)
    case server(code: Int, status: String, message: String)
}

enum NXUserFactoryError {
    case unableToEncodeData
}

enum NXUserFactoryState {
    case userCreated(Data)
    case sucess
}
