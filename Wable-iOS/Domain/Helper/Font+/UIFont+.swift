//
//  UIFont+.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/1/25.
//


import UIKit

extension UIFont {
    enum Typography {
        case head0, head1, head2
        case body1, body2, body3, body4
        case caption1, caption2, caption3, caption4, caption5
        
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
        
        var kerning: CGFloat {
            return size * -0.01
        }
        
        var lineHeight: CGFloat {
            return size * 1.6
        }
        
        var baselineOffset: CGFloat { return (lineHeight - size) / 3 }
    }
    
    static func pretendard(_ style: Typography) -> UIFont {
        return UIFont(name: style.fontName, size: style.size) ?? .systemFont(ofSize: style.size)
    }
}
