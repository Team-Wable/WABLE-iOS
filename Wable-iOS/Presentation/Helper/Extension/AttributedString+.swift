//
//  AttributedString+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/21/25.
//

import UIKit

extension AttributedString {
    
    // MARK: - addUnderline
    
    /// 전체 텍스트에 밑줄 스타일을 추가합니다.
    ///
    /// - Parameter style: 적용할 밑줄 스타일 (기본값: .single)
    /// - Returns: 메서드 체이닝을 위한 AttributedString 객체
    ///
    /// - Note: 빈 문자열인 경우 아무 작업도 수행하지 않고 원본을 반환합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// // 기본 사용법
    /// var config = UIButton.Configuration.filled()
    /// config.attributedTitle = AttributedString("버튼 텍스트").addUnderline()
    /// button.configuration = config
    ///
    /// // String의 pretendardString과 함께 사용
    /// config.attributedTitle = "버튼 텍스트".pretendardString(with: .body1).addUnderline()
    /// ```
    @discardableResult
    func addUnderline(style: NSUnderlineStyle = .single) -> AttributedString {
        guard !self.characters.isEmpty else {
            return self
        }
        
        var newString = self
        var container = AttributeContainer()
        container.underlineStyle = style
        
        newString.mergeAttributes(container)
        return newString
    }
    
    /// 특정 텍스트에만 밑줄 스타일을 추가합니다.
    ///
    /// - Parameters:
    ///   - targetText: 밑줄을 추가할 대상 텍스트
    ///   - style: 적용할 밑줄 스타일 (기본값: .single)
    /// - Returns: 메서드 체이닝을 위한 AttributedString 객체
    ///
    /// - Note: 빈 문자열이거나 대상 텍스트가 빈 문자열인 경우 아무 작업도 수행하지 않고 원본을 반환합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// // 기본 사용법
    /// var config = UIButton.Configuration.filled()
    /// config.attributedTitle = AttributedString("중요한 버튼").addUnderline(to: "중요한")
    /// button.configuration = config
    ///
    /// // String의 pretendardString과 체이닝
    /// config.attributedTitle = "중요한 버튼".pretendardString(with: .body2).addUnderline(to: "중요한")
    /// ```
    @discardableResult
    func addUnderline(to targetText: String, style: NSUnderlineStyle = .single) -> AttributedString {
        guard !self.characters.isEmpty,
              !targetText.isEmpty
        else {
            return self
        }
        
        var newString = self
        if let range = newString.range(of: targetText) {
            var container = AttributeContainer()
            container.underlineStyle = style
            newString[range].mergeAttributes(container)
        }
        return newString
    }
    
    /// 특정 텍스트의 색상을 변경합니다.
    ///
    /// - Parameters:
    ///   - textColor: 적용할 텍스트 색상
    ///   - targetText: 색상을 변경할 대상 텍스트
    /// - Returns: 메서드 체이닝을 위한 AttributedString 객체
    ///
    /// - Note: 빈 문자열이거나 대상 텍스트가 빈 문자열인 경우 아무 작업도 수행하지 않고 원본을 반환합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// // 기본 사용법
    /// var config = UIButton.Configuration.filled()
    /// config.attributedTitle = AttributedString("긴급 공지").highlight(textColor: .red, to: "긴급")
    /// button.configuration = config
    ///
    /// // String의 pretendardString과 메서드 체이닝
    /// config.attributedTitle = "긴급 공지사항".pretendardString(with: .caption1).highlight(textColor: .red, to: "긴급")
    /// ```
    @discardableResult
    func highlight(textColor: UIColor, to targetText: String) -> AttributedString {
        guard !self.characters.isEmpty,
              !targetText.isEmpty
        else {
            return self
        }
        
        var newString = self
        if let range = newString.range(of: targetText) {
            var container = AttributeContainer()
            container.foregroundColor = textColor
            newString[range].mergeAttributes(container)
        }
        return newString
    }
}
