//
//  WableSheetShowable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/30/25.
//

import UIKit

// MARK: - WableSheetShowable

protocol WableSheetShowable {
    func showWableSheet(title: String, message: String?, actions: WableSheetAction...)
    func showWableSheet(title: String, message: String?, actions: [WableSheetAction])
}

extension WableSheetShowable where Self: UIViewController {
    func showWableSheet(title: String, message: String? = nil, actions: WableSheetAction...) {
        let wableSheet = WableSheetViewController(title: title, message: message)
        actions.forEach { wableSheet.addAction($0) }
        present(wableSheet, animated: true)
    }
    
    func showWableSheet(title: String, message: String?, actions: [WableSheetAction]) {
        let wableSheet = WableSheetViewController(title: title, message: message)
        wableSheet.addActions(actions)
        present(wableSheet, animated: true)
    }
    
    func showWableSheetWithCancel(title: String, message: String? = nil, action: WableSheetAction) {
        let wableSheet = WableSheetViewController(title: title, message: message)
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        wableSheet.addActions(cancelAction, action)
        present(wableSheet, animated: true)
    }
}

// MARK: - UIViewController Extension

extension UIViewController: WableSheetShowable {}
