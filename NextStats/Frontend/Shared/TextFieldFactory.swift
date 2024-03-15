//
//  TextFieldFactory.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/12/23.
//  Copyright © 2023 Jon Alaniz. All rights reserved.
//

import UIKit

class TextFieldFactory {
    static func createTextField(placeholder: String,
                                textContentType: UITextContentType,
                                autocapitalizationType: UITextAutocapitalizationType,
                                autocorrectionType: UITextAutocorrectionType,
                                keyboardType: UIKeyboardType,
                                returnKeyType: UIReturnKeyType) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.textContentType = textContentType
        textField.autocapitalizationType = autocapitalizationType
        textField.autocorrectionType = autocorrectionType
        textField.keyboardType = keyboardType
        textField.returnKeyType = returnKeyType

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))

        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.borderStyle = .none
        textField.layoutIfNeeded()

        return textField
    }
}
