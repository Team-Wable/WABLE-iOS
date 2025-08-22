//
//  NSMutableAttributedString+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/1/25.
//

import UIKit

extension NSMutableAttributedString {
    
    // MARK: - addUnderline

    /// 전체 텍스트에 밑줄 스타일을 추가합니다.
    ///
    /// - Parameter style: 적용할 밑줄 스타일 (기본값: .single)
    /// - Returns: 메서드 체이닝을 위한 NSMutableAttributedString 객체
    ///
    /// - Note: 빈 문자열인 경우 아무 작업도 수행하지 않고 원본을 반환합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// // 기본 사용법
    /// let attributedText = NSMutableAttributedString(string: "안녕하세요")
    /// attributedText.addUnderline()
    /// label.attributedText = attributedText
    ///
    /// // pretendardString과 함께 메서드 체이닝
    /// label.attributedText = "안녕하세요".pretendardString(with: .body1).addUnderline()
    /// ```
    @discardableResult
    func addUnderline(style: NSUnderlineStyle = .single) -> NSMutableAttributedString {
        guard !string.isEmpty else {
            return self
        }
        
        addAttribute(.underlineStyle, value: style.rawValue, range: NSRange(location: 0, length: length))
        return self
    }
    
    /// 특정 텍스트에만 밑줄 스타일을 추가합니다.
    ///
    /// - Parameters:
    ///   - targetText: 밑줄을 추가할 대상 텍스트
    ///   - style: 적용할 밑줄 스타일 (기본값: .single)
    /// - Returns: 메서드 체이닝을 위한 NSMutableAttributedString 객체
    ///
    /// - Note: 빈 문자열이거나 대상 텍스트가 빈 문자열인 경우 아무 작업도 수행하지 않고 원본을 반환합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// // 기본 사용법
    /// let attributedText = NSMutableAttributedString(string: "안녕하세요 반갑습니다")
    /// attributedText.addUnderline(to: "반갑습니다")
    /// label.attributedText = attributedText
    ///
    /// // pretendardString과 함께 메서드 체이닝
    /// label.attributedText = "중요한 공지사항입니다".pretendardString(with: .head3).addUnderline(to: "중요한")
    /// ```
    @discardableResult
    func addUnderline(to targetText: String, style: NSUnderlineStyle = .single) -> NSMutableAttributedString {
        guard !string.isEmpty,
              !targetText.isEmpty
        else {
            return self
        }
        
        let range = (string as NSString).range(of: targetText)
        guard range.location != NSNotFound else {
            return self
        }
        
        addAttribute(.underlineStyle, value: style.rawValue, range: range)
        return self
    }
    
    // MARK: - highlight
    
    /// 특정 텍스트의 색상을 변경합니다.
    ///
    /// - Parameters:
    ///   - textColor: 적용할 텍스트 색상
    ///   - targetText: 색상을 변경할 대상 텍스트
    /// - Returns: 메서드 체이닝을 위한 NSMutableAttributedString 객체
    ///
    /// - Note: 빈 문자열이거나 대상 텍스트가 빈 문자열인 경우 아무 작업도 수행하지 않고 원본을 반환합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// // 기본 사용법
    /// let attributedText = NSMutableAttributedString(string: "중요한 공지사항입니다")
    /// attributedText.highlight(textColor: .red, to: "중요한")
    /// label.attributedText = attributedText
    ///
    /// // pretendardString 및 다른 메서드와 함께 체이닝
    /// label.attributedText = "중요한 공지사항입니다".pretendardString(with: .body2).highlight(textColor: .red, to: "중요한")
    /// ```
    @discardableResult
    func highlight(textColor: UIColor, to targetText: String) -> NSMutableAttributedString {
        guard !string.isEmpty,
              !targetText.isEmpty
        else {
            return self
        }
        
        let range = (string as NSString).range(of: targetText)
        guard range.location != NSNotFound else {
            return self
        }
        
        addAttribute(.foregroundColor, value: textColor, range: range)
        return self
    }
}
