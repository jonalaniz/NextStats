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
        let imageString = sfSymbolAttachedAttributedString(image, color: color)
        self.insert(imageString, at: 0)
    }

    func suffixSFSymbol(_ symbol: UIImage, color: UIColor) {
        let imageString = sfSymbolAttachedAttributedString(symbol, color: color)
        self.append(imageString)
    }

    private func sfSymbolAttachedAttributedString(_ image: UIImage, color: UIColor) -> NSAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image.withTintColor(color)

        return NSAttributedString(attachment: attachment)
    }
}
