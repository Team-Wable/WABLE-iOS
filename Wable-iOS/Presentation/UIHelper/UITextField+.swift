//
//  UITextField+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import UIKit

extension UITextField {
    
    // MARK: - setPretendard

    /// 주어진 `Pretendard` 스타일을 `UITextField`의 기본 텍스트 속성에 적용합니다.
    ///
    /// - Parameter style: 적용할 `UIFont.Pretendard` 스타일
    ///
    /// 사용 예시:
    /// ```swift
    /// let textField = UITextField()
    /// textField.setPretendard(with: .body1)
    /// textField.attributedPlaceholder = "Enter your text".pretendardString(with: .body1)
    /// ```
    func setPretendard(with style: UIFont.Pretendard) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.maximumLineHeight = style.lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard(style),
            .kern: style.kerning,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: style.baselineOffset
        ]
        
        self.defaultTextAttributes = attributes
    }
}
