//
//  Double+IsReal.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/20/22.
//  Copyright © 2022 Jon Alaniz. All rights reserved.
//

import Foundation

extension Double {
    func isNotReal() -> Bool {
        if self.isNaN || self.isInfinite {
            return true
        }

        return false
    }
}
