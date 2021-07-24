//
//  String+Attributed.swift
//  NextStats
//
//  Created by Jon Alaniz on 6/29/21.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import UIKit

extension String {
    /// Returns the String as an NSAttributedString with foreground color of QuaternaryLabel
    func attributedWithQuaternaryColor() -> NSAttributedString {
        return NSAttributedString(string: self,
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.quaternaryLabel])
    }
}
