//
//  ScreenAdjustable.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import UIKit

/// `ScreenAdjustable` 프로토콜은 디바이스 화면 크기에 맞게 `CGFloat` 및 `Int` 값을 조정할 수 있도록 합니다.
///
/// - `adjusted`: 기준 너비(375pt)에 따라 조정된 값
/// - `adjustedH`: 기준 높이(812pt)에 따라 조정된 값
///
/// 이를 통해 다양한 디바이스에서 일관된 크기를 유지할 수 있도록 합니다.
///
/// 사용 예시:
/// ```swift
/// let width: CGFloat = 20.adjusted
/// let height: CGFloat = 40.adjustedH
/// ```
protocol ScreenAdjustable {
    /// 기준 너비(375pt)를 기준으로 조정된 값
    var adjusted: CGFloat { get }
    
    /// 기준 높이(812pt)를 기준으로 조정된 값
    var adjustedH: CGFloat { get }
}

extension CGFloat: ScreenAdjustable {
    /// 기준 해상도에 대한 너비 비율 (기본값: 375pt)
    private static let widthRatio: CGFloat = UIScreen.main.bounds.width / 375
    
    /// 기준 해상도에 대한 높이 비율 (기본값: 812pt)
    private static let heightRatio: CGFloat = UIScreen.main.bounds.height / 812
    
    /// 현재 `CGFloat` 값을 화면 너비에 맞게 조정합니다.
    ///
    /// - Returns: `UIScreen.main.bounds.width`를 기준으로 계산된 크기
    ///
    /// 사용 예시:
    /// ```swift
    /// let adjustedValue = 16.0.adjusted
    /// ```
    var adjusted: CGFloat {
        return self * Self.widthRatio
    }
    
    /// 현재 `CGFloat` 값을 화면 높이에 맞게 조정합니다.
    ///
    /// - Returns: `UIScreen.main.bounds.height`를 기준으로 계산된 크기
    ///
    /// 사용 예시:
    /// ```swift
    /// let adjustedHeight = 20.0.adjustedH
    /// ```
    var adjustedH: CGFloat {
        return self * Self.heightRatio
    }
}

extension Int: ScreenAdjustable {
    /// 현재 `Int` 값을 화면 너비에 맞게 조정합니다.
    ///
    /// - Returns: `UIScreen.main.bounds.width`를 기준으로 계산된 크기
    ///
    /// 사용 예시:
    /// ```swift
    /// let adjustedWidth = 20.adjusted
    /// ```
    var adjusted: CGFloat {
        return CGFloat(self).adjusted
    }
    
    /// 현재 `Int` 값을 화면 높이에 맞게 조정합니다.
    ///
    /// - Returns: `UIScreen.main.bounds.height`를 기준으로 계산된 크기
    ///
    /// 사용 예시:
    /// ```swift
    /// let adjustedHeight = 40.adjustedH
    /// ```
    var adjustedH: CGFloat {
        return CGFloat(self).adjustedH
    }
}
