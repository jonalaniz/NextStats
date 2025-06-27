//
//  NXDataManagerDelegate.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/17/21.
//  Copyright © 2021 Jon Alaniz.

import Foundation

protocol NXDataManagerDelegate: AnyObject {
    func stateDidChange(_ state: NXDataManagerState)
}

enum NXDataManagerState {
    case fetchingData
    case dataCaptured(_ sections: [TableSection])
}
