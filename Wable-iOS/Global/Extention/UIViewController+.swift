//
//  UIViewController+.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit

extension UIViewController {
    var statusBarHeight: CGFloat {
        return UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20
    }
}

extension UIViewController {
    func dismissKeyboardTouchOutside(delegate: UIGestureRecognizerDelegate? = nil) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = delegate
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
