//
//  UIFont+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import UIKit

extension UIFont {
    
    // MARK: - Pretendard

    /// `Pretendard`는 다양한 텍스트 스타일을 정의하는 열거형입니다.
    ///
    /// - `head0`, `head1`, `head2`: 헤드라인 스타일 (큰 텍스트)
    /// - `body1`, `body2`, `body3`, `body4`: 본문 스타일
    /// - `caption1`, `caption2`, `caption3`, `caption4`, `caption5`: 캡션 스타일 (작은 텍스트)
    ///
    /// 각 스타일은 특정 폰트 패밀리(`Pretendard`)와 크기, 자간, 줄 높이를 갖습니다.
    enum Pretendard {
        case head0, head1, head2
        case body1, body2, body3, body4
        case caption1, caption2, caption3, caption4, caption5
        
        /// 해당 스타일의 폰트 이름을 반환합니다.
        ///
        /// - `SemiBold`: `head0`, `head1`, `head2`, `body1`, `body3`, `caption1`, `caption3`
        /// - `Medium`: `caption5`
        /// - `Regular`: 그 외 스타일
        var fontName: String {
            switch self {
            case .head0, .head1, .head2, .body1, .body3, .caption1, .caption3:
                return "Pretendard-SemiBold"
            case .caption5:
                return "Pretendard-Medium"
            default:
                return "Pretendard-Regular"
            }
        }
        
        /// 해당 스타일의 폰트 크기를 반환합니다.
        ///
        /// - Returns: 스타일에 따른 `CGFloat` 크기 값
        var size: CGFloat {
            switch self {
            case .head0: return 24
            case .head1: return 20
            case .head2: return 18
            case .body1, .body2: return 16
            case .body3, .body4: return 14
            case .caption1, .caption2: return 13
            case .caption3, .caption4: return 12
            case .caption5: return 11
            }
        }
        
        /// 해당 스타일의 자간(Kerning)을 반환합니다.
        ///
        /// - 기본적으로 폰트 크기의 -1% 값을 적용하여 자연스러운 글자 간격을 유지합니다.
        /// - Returns: `CGFloat` 값 (음수 값 적용)
        var kerning: CGFloat {
            return size * -0.01
        }
        
        /// 해당 스타일의 줄 높이(Line Height)를 반환합니다.
        ///
        /// - 기본적으로 폰트 크기의 1.6배를 적용하여 가독성을 고려합니다.
        /// - Returns: `CGFloat` 값
        var lineHeight: CGFloat {
            return size * 1.6
        }
        
        /// 해당 스타일의 베이스라인 오프셋(Baseline Offset)을 반환합니다.
        ///
        /// - 기본적으로 (줄 높이 - 폰트 크기)의 1/3을 적용하여 시각적 정렬을 조정합니다.
        /// - Returns: `CGFloat` 값
        var baselineOffset: CGFloat { return (lineHeight - size) / 3 }
    }
    
    /// `Pretendard` 폰트를 반환하는 정적 메서드.
    ///
    /// - Parameter style: `Pretendard` 스타일(enum)
    /// - Returns: 해당 스타일에 맞는 `UIFont` 객체를 반환합니다.
    ///
    /// 사용 예시:
    /// ```swift
    /// let titleFont = UIFont.pretendard(.head1)
    /// let captionFont = UIFont.pretendard(.caption3)
    /// ```
    static func pretendard(_ style: Pretendard) -> UIFont {
        return UIFont(name: style.fontName, size: style.size) ?? .systemFont(ofSize: style.size)
    }
}
