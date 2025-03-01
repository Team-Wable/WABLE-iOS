//
//  UILabel+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/1/25.
//


import UIKit

extension UILabel {
    func setLabel(_ style: UIFont.Typography) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.maximumLineHeight = style.lineHeight

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard(style),
            .kern: style.kerning,
            .baselineOffset: style.baselineOffset,
            .paragraphStyle: paragraphStyle
        ]

        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: attributes)
    }
}
