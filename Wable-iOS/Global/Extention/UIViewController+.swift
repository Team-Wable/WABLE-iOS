//
//  UIViewController+.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/16/24.
//

import UIKit

extension UIViewController: UIGestureRecognizerDelegate {
    
        var statusBarHeight: CGFloat {
            return UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20
        }
    
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        tap.delegate = self // 제스처 delegate 설정
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }

    // 버튼 터치는 제스처가 받지 않도록 설정
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchedView = touch.view, touchedView is UIButton {
            return false
        }
        return true
    }
}
