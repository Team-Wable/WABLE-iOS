//
//  AttributedString+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/21/25.
//


import UIKit

extension AttributedString {
    /// 기본 문자열에 밑줄 스타일을 적용한 `AttributedString`을 반환합니다.
    ///
    /// - Returns: 밑줄이 적용된 `AttributedString` 객체
    ///
    /// 사용 예시:
    /// ```swift
    /// let button = UIButton()
    /// var config = UIButton.Configuration.filled()
    /// config.attributedTitle = "보러가기".pretendardString(with: .body4).withUnderline()
    /// button.configuration = config
    /// ```
    func withUnderline() -> AttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: NSAttributedString(self))
        
        mutableAttributedString.addAttribute(.underlineStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: NSRange(location: 0, length: mutableAttributedString.length))
        
        return AttributedString(mutableAttributedString)
    }
}
