//
//  UIViewController+.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

extension UIViewController {
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
