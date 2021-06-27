//
//  URL+isValid.swift
//  NextStats
//
//  Created by Jon Alaniz on 8/20/20.
//  Copyright © 2020 Jon Alaniz
//

import Foundation

// swiftlint:disable line_length
let urlRegEx = #"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?$"#

// swiftlint:disable line_length
let ipRegEx = #"^(^192\.168\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])?\:([0-9]+)$)|(^172\.([1][6-9]|[2][0-9]|[3][0-1])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])?\:([0-9]+)$)|(^10\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])\.([0-9]|[0-9][0-9]|[0-2][0-5][0-5])?\:?([0-9]+)?$)"#

extension String {
    func isValidURL() -> Bool {
        let urlTest = NSPredicate(format: "SELF MATCHES %@", urlRegEx)
        let isValid = urlTest.evaluate(with: self)

        return isValid
    }

    func isValidIPAddress() -> Bool {
        let urlTest = NSPredicate(format: "SELF MATCHES %@", ipRegEx)
        let isValid = urlTest.evaluate(with: self)

        return isValid
    }
}
