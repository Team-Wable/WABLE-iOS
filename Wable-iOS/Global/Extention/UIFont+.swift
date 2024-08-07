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
    
    class var head0: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 24.adjusted)! }
    class var head1: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 20.adjusted)! }
    class var head2: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 18.adjusted)! }

    class var body1: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 16.adjusted)! }
    class var body2: UIFont { return UIFont(name: AppFontName.regularFont.rawValue, size: 16.adjusted)! }
    class var body3: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 14.adjusted)! }
    class var body4: UIFont { return UIFont(name: AppFontName.regularFont.rawValue, size: 14.adjusted)! }

    class var caption1: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 13.adjusted)! }
    class var caption2: UIFont { return UIFont(name: AppFontName.regularFont.rawValue, size: 13.adjusted)! }
    class var caption3: UIFont { return UIFont(name: AppFontName.semiBoldFont.rawValue, size: 12.adjusted)! }
    class var caption4: UIFont { return UIFont(name: AppFontName.regularFont.rawValue, size: 12.adjusted)! }
    
}
