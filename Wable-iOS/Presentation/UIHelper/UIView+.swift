//
//  UIView+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import UIKit

extension UIView {
    
    // MARK: - addSubviews

    /// 여러 개의 `UIView`를 한 번에 `addSubview(_:)`하는 메서드.
    ///
    /// - Parameter views: 추가할 `UIView` 인스턴스들을 가변 매개변수(`variadic parameter`)로 전달.
    ///
    /// 사용 예시:
    /// ```swift
    /// let containerView = UIView()
    /// let imageView = UIImageView()
    /// let titleLabel = UILabel()
    ///
    /// containerView.addSubviews(imageView, titleLabel)
    /// ```
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            addSubview(view)
        }
    }
    
    // MARK: - roundCorners

    /// 지정한 모서리에만 `cornerRadius`를 적용합니다.
    ///
    /// - Parameters:
    ///   - corners: 적용할 모서리들을 지정하는 `CACornerMask` 값.
    ///   - radius: 모서리에 적용할 `cornerRadius` 값.
    ///
    /// 사용 예시:
    /// ```swift
    /// let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    /// view.backgroundColor = .red
    ///
    /// // 상단 왼쪽, 상단 오른쪽 모서리만 둥글게 처리
    /// view.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10)
    /// ```
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
        self.layer.masksToBounds = true
    }
}
