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
    
    // MARK: - addPadding

    /// `UITextField`의 왼쪽 및 오른쪽에 패딩을 추가합니다.
    ///
    /// - Parameters:
    ///   - left: 왼쪽 패딩 값 (`CGFloat`). 기본값은 `nil`
    ///   - right: 오른쪽 패딩 값 (`CGFloat`). 기본값은 `nil`
    ///
    /// 사용 예시:
    /// ```swift
    /// let textField = UITextField()
    /// textField.addPadding(left: 10, right: 10)
    /// ```
    func addPadding(left: CGFloat? = nil, right: CGFloat? = nil) {
        if let left {
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: 0))
            leftViewMode = .always
        }
        
        if let right {
            rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: 0))
            rightViewMode = .always
        }
    }
}
