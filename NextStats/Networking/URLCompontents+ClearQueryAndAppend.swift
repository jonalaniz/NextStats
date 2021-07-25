//
//  URLCompontents+ClearQueryAndAppend.swift
//  URLCompontents+ClearQueryAndAppend
//
//  Created by Jon Alaniz on 7/25/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

extension URLComponents {
    mutating func clearQueryAndAppend(endpoint: Endpoints) {
        self.queryItems = nil
        self.path = endpoint.rawValue
    }
}
