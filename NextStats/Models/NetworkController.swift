//
//  NetworkController.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/8/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

class NetworkController {
    
    enum FetchError: Error {
        case networkError
        case missingResponse
        case unexpectedResponse(Int)
        case invalidData
        case invalidJSON(Error)
        case unauthorized
    }
    
    func fetch<T: Any>(completion: @escaping (Result<T, FetchError>) -> Void) {
        
    }
}
