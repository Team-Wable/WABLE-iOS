//
//  UIViewController+KeyboardHandling.swift
//  Wable-iOS
//
//  Created by YOUJIM on 6/18/25.
//


import UIKit

// MARK: - Keyboard Handling Extension

extension UIViewController {
    func enableKeyboardHandling() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardHide(notification: notification)
        }
    }
    
    func disableKeyboardHandling() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Helper Method

private extension UIViewController {
    private func handleKeyboardShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        animateViewTransform(
            window: window,
            yOffset: -(keyboardFrame.cgRectValue.height - (window?.safeAreaInsets.bottom ?? 0)),
            duration: animationDuration,
            curve: animationCurve
        )
    }
    
    private func handleKeyboardHide(notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            return
        }
        
        animateViewTransform(
            window: UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow },
            yOffset: 0,
            duration: animationDuration,
            curve: animationCurve
        )
    }
    
    private func animateViewTransform(window: UIWindow?, yOffset: CGFloat, duration: Double, curve: UInt) {
        guard let window = window else { return }
        
        let animationOptions = UIView.AnimationOptions(rawValue: curve << 16)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [animationOptions, .beginFromCurrentState],
            animations: {
                window.transform = CGAffineTransform(translationX: 0, y: yOffset)
            },
            completion: nil
        )
    }
}
