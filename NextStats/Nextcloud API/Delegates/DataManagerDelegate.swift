//
//  DataManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/26/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

protocol DataManagerDelegate: AnyObject {
    func stateDidChange(_ state: DataManagerStatus)
}
