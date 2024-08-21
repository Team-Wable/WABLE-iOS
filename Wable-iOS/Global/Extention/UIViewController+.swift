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
    
    func dismissKeyboard() {
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(UIViewController.dismissKeyboardTouchOutside))
      tap.cancelsTouchesInView = false
      view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardTouchOutside() {
      view.endEditing(true)
    }
}
