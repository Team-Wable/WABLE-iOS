//
//  UIAlertShowable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/30/25.
//

import UIKit

// MARK: - UIAlertShowable

protocol UIAlertShowable: AnyObject {
    func showAlert(title: String, message: String?, actions: UIAlertAction...)
}

extension UIAlertShowable where Self: UIViewController {
    func showAlert(title: String, message: String? = nil, actions: UIAlertAction...) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    func showAlertWithCancel(title: String, message: String? = nil, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

// MARK: - UIViewController Extension

extension UIViewController: UIAlertShowable {}
