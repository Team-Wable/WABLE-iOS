//
//  String+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import UIKit

extension String {
    
    // MARK: - pretendardString

    /// 주어진 `Pretendard` 스타일을 적용한 `NSMutableAttributedString`을 반환합니다.
    ///
    /// - Parameter style: 적용할 `UIFont.Pretendard` 스타일
    /// - Returns: `NSMutableAttributedString` 객체
    ///
    /// 사용 예시 (`UILabel`에서 `attributedText` 설정):
    /// ```swift
    /// let label = UILabel()
    /// label.attributedText = "Hello, world!".pretendardString(with: .caption3)
    /// ```
    func pretendardString(with style: UIFont.Pretendard) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.maximumLineHeight = style.lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard(style),
            .kern: style.kerning,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: style.baselineOffset
        ]
        
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
    
    // MARK: - pricedownString

    /// 주어진 `Pricedown` 스타일을 적용한 `NSMutableAttributedString`을 반환합니다.
    ///
    /// - Parameter style: 적용할 `UIFont.Pricedown` 스타일
    /// - Returns: `NSMutableAttributedString` 객체
    ///
    /// 사용 예시 (`UILabel`에서 `attributedText` 설정):
    /// ```swift
    /// let label = UILabel()
    /// label.attributedText = "Hello, world!".pricedownString(with: .black)
    /// ```
    func pricedownString(with style: UIFont.Pricedown) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = style.lineHeight
        paragraphStyle.maximumLineHeight = style.lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pricedown(style),
            .kern: style.kerning,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: style.baselineOffset
        ]
        
        return NSMutableAttributedString(string: self, attributes: attributes)
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
        return AttributedString(self.pretendardString(with: style))
    }
    
    // MARK: - truncated
    
    /// 문자열을 지정된 길이로 제한하고 필요한 경우 생략 부호를 추가합니다.
    /// - Parameters:
    ///   - maxLength: 최대 문자 수
    ///   - appendEllipsis: 생략 부호 추가 여부
    /// - Returns: 제한된 문자열
    func truncated(toLength maxLength: Int, appendingEllipsis: Bool = true) -> String {
        if count <= maxLength {
            return self
        }
        
        let index = self.index(startIndex, offsetBy: maxLength)
        let truncated = self[..<index]
        
        return appendingEllipsis ? "\(truncated)..." : "\(truncated)"
    }
}
