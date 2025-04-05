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
    
    // MARK: - Pretendard style Initializer
    
    /// Pretendard 폰트 스타일을 적용한 UITextField를 생성하는 편의 생성자입니다.
    ///
    /// 이 생성자는 `defaultTextAttributes`를 가장 먼저 설정하여 나중에 설정하는
    /// 다른 속성(textColor, textAlignment 등)이 기존 폰트와 자간 설정을 덮어씌우지 않도록 합니다.
    ///
    /// - Parameters:
    ///   - style: UIFont.Pretendard 스타일
    ///   - text: 초기 텍스트 (선택 사항)
    ///   - placeholder: 플레이스홀더 텍스트 (선택 사항)
    ///
    /// - 사용 예시:
    /// ```
    /// let nameField = UITextField(pretendardStyle: .body1, placeholder: "이름을 입력하세요")
    /// nameField.textColor = .black // 폰트와 자간 설정은 유지됨
    /// ```
    ///
    /// - Note: UITextField는 한 줄 텍스트만 지원하므로 baselineOffset과 lineHeight는 적용하지 않습니다.
    convenience init(
        pretendardStyle style: UIFont.Pretendard,
        text: String? = nil,
        placeholder: String? = nil
    ) {
        self.init(frame: .zero)
        
        let font = UIFont.pretendard(style)
        
        // 기본 속성 딕셔너리 생성 (폰트와 자간만 포함)
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .kern: style.kerning
        ]
        
        // 중요: defaultTextAttributes를 가장 먼저 설정하여 다른 속성들이 이를 덮어씌우지 않도록 함
        self.defaultTextAttributes = defaultAttributes
        
        self.font = font
        
        if let text {
            self.text = text
        }
        
        if let placeholder {
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: defaultAttributes)
        }
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
