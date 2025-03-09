//
//  ConstraintMaker.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//


import UIKit

import SnapKit

extension ConstraintMaker {
    /// 너비 값을 설정할 때 자동으로 `adjustedWidth`를 적용하는 메서드입니다.
    ///
    /// 기준 너비(375pt)에 따라 현재 기기의 화면 너비에 맞게 값을 조정합니다.
    ///
    /// - Parameter float: 조정할 CGFloat 값
    /// - Returns: ConstraintMakerEditable 객체
    ///
    /// 사용 예시:
    /// ```swift
    /// view.snp.makeConstraints {
    ///     $0.widthEqualTo(100) // $0.width.equalTo(100.adjustedWidth)와 같은 효과
    /// }
    /// ```
    @discardableResult
    func widthEqualTo(_ float: CGFloat) -> ConstraintMakerEditable {
        return self.width.equalTo(float.adjustedWidth)
    }
    
    /// 높이 값을 설정할 때 자동으로 `adjustedHeight`를 적용하는 메서드입니다.
    ///
    /// 기준 높이(812pt)에 따라 현재 기기의 화면 높이에 맞게 값을 조정합니다.
    ///
    /// - Parameter float: 조정할 CGFloat 값
    /// - Returns: ConstraintMakerEditable 객체
    ///
    /// 사용 예시:
    /// ```swift
    /// view.snp.makeConstraints {
    ///     $0.heightEqualTo(200) // $0.height.equalTo(200.adjustedHeight)와 같은 효과
    /// }
    /// ```
    @discardableResult
    func heightEqualTo(_ float: CGFloat) -> ConstraintMakerEditable {
        return self.height.equalTo(float.adjustedHeight)
    }
}

extension CGFloat {
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
    var adjustedWidth: CGFloat {
        return self * Self.widthRatio
    }
    
    /// 현재 `CGFloat` 값을 화면 높이에 맞게 조정합니다.
    ///
    /// - Returns: `UIScreen.main.bounds.height`를 기준으로 계산된 크기
    ///
    /// 사용 예시:
    /// ```swift
    /// let adjustedHeight = 20.0.adjustedHeight
    /// ```
    var adjustedHeight: CGFloat {
        return self * Self.heightRatio
    }
}

extension Int {
    /// 현재 `Int` 값을 화면 너비에 맞게 조정합니다.
    ///
    /// - Returns: `UIScreen.main.bounds.width`를 기준으로 계산된 크기
    ///
    /// 사용 예시:
    /// ```swift
    /// let adjustedWidth = 20.adjusted
    /// ```
    var adjustedWidth: CGFloat {
        return CGFloat(self).adjustedWidth
    }
    
    /// 현재 `Int` 값을 화면 높이에 맞게 조정합니다.
    ///
    /// - Returns: `UIScreen.main.bounds.height`를 기준으로 계산된 크기
    ///
    /// 사용 예시:
    /// ```swift
    /// let adjustedHeight = 40.adjustedHeight
    /// ```
    var adjustedHeight: CGFloat {
        return CGFloat(self).adjustedHeight
    }
}

