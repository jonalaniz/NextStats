//
//  TextFieldFactory.swift
//  NextStats
//
//  Created by Jon Alaniz on 10/12/23.
//  Copyright © 2023 Jon Alaniz. All rights reserved.
//

import UIKit

enum TextFieldType {
    case email, normal, password, URL
}

class TextFieldFactory {
    static func textField(type: TextFieldType, placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.returnKeyType = .done

        switch type {
        case .email:
            textField.textContentType = .emailAddress
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.keyboardType = .emailAddress
        case .normal:
            textField.textContentType = .name
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .default
            textField.keyboardType = .default
        case .password:
            textField.textContentType = .password
            textField.isSecureTextEntry = true
            textField.autocapitalizationType = .words
            textField.autocorrectionType = .no
            textField.keyboardType = .default
        case .URL:
            textField.textContentType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.keyboardType = .URL
        }

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))

        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.borderStyle = .none
        textField.layoutIfNeeded()

        return textField
    }
}
