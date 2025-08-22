//
//  UIColor+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//

import UIKit

extension UIColor {
    
    // MARK: - HEX 초기화
    
    /// HEX 코드 문자열로부터 `UIColor` 인스턴스를 생성하는 편의 이니셜라이저.
    ///
    /// - Parameters:
    ///   - hex: 색상을 나타내는 HEX 문자열(예: "#FFFFFF" 또는 "FFFFFF")
    ///   - alpha: 색상의 알파값(투명도). 기본값은 1.0(불투명)
    ///
    /// 사용 예시:
    /// ```swift
    /// let backgroundColor = UIColor("#F5F5F5")
    /// let textColor = UIColor("333333", alpha: 0.8)
    /// ```
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "유효하지 않은 HEX 코드입니다.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
