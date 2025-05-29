//
//  WableSheetShowable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/30/25.
//

import UIKit

protocol WableSheetShowable {
    func showWableSheet(title: String, message: String?, actions: WableSheetAction...)
}

extension WableSheetShowable where Self: UIViewController {
    func showWableSheet(title: String, message: String? = nil, actions: WableSheetAction...) {
        let wableSheet = WableSheetViewController(title: title, message: message)
        actions.forEach { wableSheet.addAction($0) }
        present(wableSheet, animated: true)
    }
    
    func showConfirmSheet(title: String, message: String? = nil, confirmAction: WableSheetAction) {
        let wableSheet = WableSheetViewController(title: title, message: message)
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        wableSheet.addActions(cancelAction, confirmAction)
        present(wableSheet, animated: true)
    }
}

extension UIViewController: WableSheetShowable {}
