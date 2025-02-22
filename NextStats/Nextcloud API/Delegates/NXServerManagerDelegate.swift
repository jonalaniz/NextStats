//
//  ServerManagerDelegate.swift
//  ServerManagerDelegate
//
//  Created by Jon Alaniz on 8/9/21.
//  Copyright © 2021 Jon Alaniz.
//

import Foundation

enum DataManagerStatus {
    case ready
    case loading
    case dataUpdated
    case error(Error)
}

protocol NXServerManagerDelegate: AnyObject {
    func deauthorizationFailed(server: NextServer)
    func serversDidChange(refresh: Bool)
    func pingedServer(at index: Int, status: ServerStatus)
    func unauthorized()
    func serverWiped()
}
