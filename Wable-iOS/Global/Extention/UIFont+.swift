//
//  UIFont+.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/6/24.
//

import UIKit

enum AppFontName: String {
    case semiBoldFont = "Pretendard-SemiBold"
    case regularFont = "Pretendard-Regular"
}

extension UIFont {
    static var head0: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 24.adjusted)! }
    static var head1: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 20.adjusted)! }
    static var head2: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 18.adjusted)! }

    static var body1: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 16.adjusted)! }
    static var body2: UIFont { return UIFont(name: AppFontName.regularFont.rawValue, size: 16.adjusted)! }
    static var body3: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 14.adjusted)! }
    static var body4: UIFont { return UIFont(name: AppFontName.regularFont.rawValue, size: 14.adjusted)! }

    static var caption1: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 13.adjusted)! }
    static var caption2: UIFont { return UIFont(name: AppFontName.regularFont.rawValue, size: 13.adjusted)! }
    static var caption3: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 12.adjusted)! }
    static var caption4: UIFont { return UIFont(name: AppFontName.regularFont.rawValue, size: 12.adjusted)! }
}
