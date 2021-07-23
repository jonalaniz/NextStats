//
//  UIButton+SFSymbolWithText.swift
//  UIButton+SFSymbolWithText
//
//  Created by Jon Alaniz on 7/22/21.
//  Copyright © 2021 Jon Alaniz. All rights reserved.
//

import UIKit

extension UIButton {
    func sfSymbolWithText(symbol: String, text: String) {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: symbol)?.withTintColor(.white)

        let imageString = NSMutableAttributedString(attachment: attachment)
        let text = NSAttributedString(string: " \(text)")
        imageString.append(text)

        self.setAttributedTitle(imageString, for: .normal)
    }
}
