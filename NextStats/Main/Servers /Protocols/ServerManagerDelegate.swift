//
//  ServerManagerDelegate.swift
//  ServerManagerDelegate
//
//  Created by Jon Alaniz on 8/9/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import Foundation

protocol ServerManagerDelegate: AnyObject {
    func serversDidChange(refresh: Bool)
    func pingedServer(at index: Int, isOnline: Bool)
    func selected(server: NextServer)
}
