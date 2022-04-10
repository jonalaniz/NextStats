//
//  URLCompontents+ClearQueryAndAppend.swift
//  URLCompontents+ClearQueryAndAppend
//
//  Created by Jon Alaniz on 7/25/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

extension URLComponents {
    mutating func clearQueryAndAppend(endpoint: Endpoints) {
        self.queryItems = nil
        self.query = endpoint.query()

        self.path += endpoint.rawValue
    }

    mutating func replacePathWith(endpoint: Endpoints) {
        self.queryItems = nil
        self.query = endpoint.query()

        self.path = endpoint.rawValue
    }
}
