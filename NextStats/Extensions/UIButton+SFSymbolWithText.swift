//
//  UIButton+SFSymbolWithText.swift
//  UIButton+SFSymbolWithText
//
//  Created by Jon Alaniz on 7/22/21.
//  Copyright © 2021 Jon Alaniz.
//

import UIKit
// TODO: Either use or remove this
extension UIButton {
    func sfSymbolWithText(symbol: SFSymbol, text: String, color: UIColor) {
        let attachment = NSTextAttachment()
        attachment.image = symbol.image?.withTintColor(color)

        let imageString = NSMutableAttributedString(attachment: attachment)
        let text = NSAttributedString(string: " \(text)")
        imageString.append(text)

        self.setAttributedTitle(imageString, for: .normal)
        self.setTitleColor(color, for: .normal)
    }
}
