//
//  UIView+.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    func makeDivisionLine() -> UIView {
        let divisionLine = UIView()
        divisionLine.backgroundColor = .gray300
        return divisionLine
    }
    
    func isValidInput(_ input: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[가-힣a-zA-Z0-9]+$", options: .caseInsensitive)
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        return matches.count > 0
    }
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: type)
    }
}
