//
//  KeyboardDismissible.swift
//  Wable-iOS
//
//  Created by YOUJIM on 8/23/25.
//


import UIKit

protocol KeyboardDismissible: UIViewController {}

extension KeyboardDismissible {
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tapGesture)
    }
}

extension UIViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
