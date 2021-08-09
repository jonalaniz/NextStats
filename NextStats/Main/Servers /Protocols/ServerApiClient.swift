//
//  ServerApiClient.swift
//  ServerApiClient
//
//  Created by Jon Alaniz on 8/9/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

protocol ServerApiClient {
    func add(_ server: NextServer)
    func remove(at index: Int)
    func serverCount() -> Int
    func getServer(at index: Int) -> NextServer
    func pingServer(at index: Int)
}
