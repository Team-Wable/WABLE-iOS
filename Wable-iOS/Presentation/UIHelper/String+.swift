//
//  String+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import UIKit

extension String {
    
    // MARK: - pretendardString

    /// 주어진 `Pretendard` 스타일을 적용한 `NSAttributedString`을 반환합니다.
    ///
    /// - Parameter style: 적용할 `UIFont.Pretendard` 스타일
    /// - Returns: `NSAttributedString` 객체
    ///
    /// 사용 예시 (`UILabel`에서 `attributedText` 설정):
    /// ```swift
    /// let label = UILabel()
    /// label.attributedText = "Hello, world!".pretendardString(with: .caption3)
    /// ```
    func pretendardString(with style: UIFont.Pretendard) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.maximumLineHeight = style.lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard(style),
            .kern: style.kerning,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: style.baselineOffset
        ]
        
        return NSAttributedString(string: self, attributes: attributes)
    }
    
    /// 주어진 `Pretendard` 스타일을 적용한 `AttributedString`을 반환합니다.
    ///
    /// - Parameter style: 적용할 `UIFont.Pretendard` 스타일
    /// - Returns: `AttributedString` 객체
    ///
    /// 사용 예시 (`UIButton`에서 `configuration`의 `attributedTitle` 설정):
    /// ```swift
    /// let button = UIButton()
    /// var config = UIButton.Configuration.filled()
    /// config.attributedTitle = "Press Me".pretendardString(with: .head2)
    /// button.configuration = config
    /// ```
    func pretendardString(with style: UIFont.Pretendard) -> AttributedString {
        let nsAttributedString: NSAttributedString = self.pretendardString(with: style)
        return AttributedString(nsAttributedString)
    }
}
