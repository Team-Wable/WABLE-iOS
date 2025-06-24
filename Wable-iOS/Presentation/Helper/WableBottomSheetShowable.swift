//
//  WableBottomSheetShowable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/30/25.
//

import UIKit

// MARK: - WableBottomSheetShowable

protocol WableBottomSheetShowable: AnyObject {
    func showBottomSheet(actions: WableBottomSheetAction...)
    func showBottomSheet(actions: [WableBottomSheetAction])
}

extension WableBottomSheetShowable where Self: UIViewController {
    func showBottomSheet(actions: WableBottomSheetAction...) {
        let wableBottomSheet = WableBottomSheetController()
        actions.forEach { wableBottomSheet.addActions($0) }
        present(wableBottomSheet, animated: true)
    }
    
    func showBottomSheet(actions: [WableBottomSheetAction]) {
        let wableBottomSheet = WableBottomSheetController()
        wableBottomSheet.addActions(actions)
        present(wableBottomSheet, animated: true)
    }
}

// MARK: - UIViewController Extension

extension UIViewController: WableBottomSheetShowable {}
