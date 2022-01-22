//
//  URL+isValid.swift
//  NextStats
//
//  Created by Jon Alaniz on 8/20/20.
//  Copyright © 2021 Jon Alaniz. All Rights Reserved.
//

import Foundation

// swiftlint:disable line_length
let urlRegEx = #"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?$"#

extension String {
    func isValidURL() -> Bool {
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        let isValid = urlTest.evaluate(with: self)

        return isValid
    }

    func isValidIPAddress() -> Bool {
        var testableString = self
        if let index = testableString.range(of: ":") {
          testableString.removeSubrange(index.lowerBound..<testableString.endIndex)
        }

        let parts = testableString.components(separatedBy: ".")
        let nums = parts.compactMap { Int($0) }
        return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
    }
}
