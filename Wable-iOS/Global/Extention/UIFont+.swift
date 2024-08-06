//
//  UIFont+.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import UIKit

enum FontName: String {
    case head0, head1, head2
    case body1, body2, body3, body4
    case caption1, caption2, caption3, caption4

    var rawValue: String {
        switch self {
        case .head0, .head1, .head2, .body1, .body3, .caption1, .caption3: return "Pretendard-SemiBold"
        case .body2, .body4, .caption2, .caption4: return "Pretendard-Regular"
        }
    }

    var size: CGFloat {
        switch self {
        case .head0: return 24.adjusted
        case .head1: return 20.adjusted
        case .head2: return 18.adjusted
        case .body1, .body2: return 16.adjusted
        case .body3, .body4: return 14.adjusted
        case .caption1, .caption2: return 13.adjusted
        case .caption3, .caption4: return 12.adjusted
        }
    }
}

extension UIFont {
    static func font(_ style: FontName) -> UIFont {
        return UIFont(name: style.rawValue, size: style.size)!
    }
}
