//
//  WableTextSheetShowable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 6/23/25.
//

import UIKit

// MARK: - WableTextSheetShowable

protocol WableTextSheetShowable {
    func showWableTextSheet(title: String, placeholder: String, actions: WableTextSheetAction...)
    func showWableTextSheet(title: String, placeholder: String, actions: [WableTextSheetAction])
}

extension WableTextSheetShowable where Self: UIViewController {
    func showWableTextSheet(title: String, placeholder: String, actions: WableTextSheetAction...) {
        let wableTextSheet = WableTextSheetViewController(title: title, placeholder: placeholder)
        actions.forEach { wableTextSheet.addAction($0) }
        present(wableTextSheet, animated: true)
    }
    
    func showWableTextSheet(title: String, placeholder: String, actions: [WableTextSheetAction]) {
        let wableTextSheet = WableTextSheetViewController(title: title, placeholder: placeholder)
        wableTextSheet.addActions(actions)
        present(wableTextSheet, animated: true)
    }
    
    func showGhostSheet(onPrimary handler: @escaping (String?) -> Void) {
        let wableTextSheet = WableTextSheetViewController(
            title: StringLiterals.Ghost.sheetTitle,
            placeholder: StringLiterals.Ghost.sheetPlaceholder
        )
        let cancel = WableTextSheetAction(title: "고민할게요", style: .gray)
        let confirm = WableTextSheetAction(title: "투명도 내리기", style: .primary, handler: handler)
        wableTextSheet.addActions(cancel, confirm)
        present(wableTextSheet, animated: true)
    }
    
    func showReportSheet(onPrimary handler: @escaping (String?) -> Void) {
        let wableTextSheet = WableTextSheetViewController(
            title: StringLiterals.Report.sheetTitle,
            placeholder: StringLiterals.Report.sheetPlaceholder
        )
        let cancel = WableTextSheetAction(title: "고민할게요", style: .gray)
        let confirm = WableTextSheetAction(title: "신고하기", style: .primary, handler: handler)
        wableTextSheet.addActions(cancel, confirm)
        present(wableTextSheet, animated: true)
    }
}

// MARK: - UIViewController Extension

extension UIViewController: WableTextSheetShowable {}
