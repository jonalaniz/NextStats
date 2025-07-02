//
//  String+Escape.swift
//  NextStats
//
//  Created by Jon Alaniz on 7/2/25.
//  Copyright © 2025 Jon Alaniz. All rights reserved.
//

import Foundation

extension String {
    func escape(
        _ characterSet: [(character: String, escapedCharacter: String)]
    ) -> String {
        var string = self

        for set in characterSet {
            string = string.replacingOccurrences(of: set.character, with: set.escapedCharacter, options: .literal)
        }

        return string
    }
}
