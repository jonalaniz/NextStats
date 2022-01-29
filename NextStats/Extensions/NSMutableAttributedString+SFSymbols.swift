//
//  NSMutableAttributedString+SFSymbols.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/29/22.
//  Copyright © 2022 Jon Alaniz. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func prefixingSFSymbol(_ symbol: String, color: UIColor) {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: symbol)?.withTintColor(color)

        let imageString = NSMutableAttributedString(attachment: attachment)

        self.insert(imageString, at: 0)
    }

    func suffixingSFSymbol(_ symbol: String, color: UIColor) {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: symbol)?.withTintColor(color)

        let imageString = NSMutableAttributedString(attachment: attachment)
        self.append(imageString)
    }
}
