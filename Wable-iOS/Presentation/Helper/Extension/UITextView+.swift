//
//  UITextView+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 4/5/25.
//


import UIKit

extension UITextView {
    /// 주어진 `Pretendard` 스타일을 `UITextView`에 적용합니다.
    ///
    /// - Parameter style: 적용할 `UIFont.Pretendard` 스타일
    /// - Parameter text: 설정할 텍스트 (기본값: 빈 문자열)
    ///
    /// 사용 예시:
    /// ```swift
    /// let textView = UITextView()
    /// textView.setPretendard(with: .body4, text: "내용이 들어갑니다")
    /// ```
    func setPretendard(with style: UIFont.Pretendard, text: String = " ") {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = (style.lineHeight - style.size) / 1.6
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard(style),
            .kern: style.kerning,
            .paragraphStyle: paragraphStyle
        ]
        
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
