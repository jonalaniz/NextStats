//
//  NSMutableAttributedString+SFSymbols.swift
//  NextStats
//
//  Created by Jon Alaniz on 1/29/22.
//  Copyright © 2022 Jon Alaniz.
//

import UIKit

extension NSMutableAttributedString {
    func prefixSFSymbol(_ image: UIImage, color: UIColor) {
        let attachment = NSTextAttachment()
        attachment.image = image.withTintColor(color)

        let imageString = NSAttributedString(attachment: attachment)
        self.insert(imageString, at: 0)
    }
}
