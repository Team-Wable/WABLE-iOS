//
//  UIStackView+.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/4/25.
//

import UIKit

extension UIStackView {
    
    // MARK: - axis Initializer

    /// `UIStackView`를 초기화하는 편의 이니셜라이저.
    ///
    /// - Parameter axis: `horizontal` 또는 `vertical` 방향을 지정하는 `NSLayoutConstraint.Axis`
    ///
    /// 사용 예시:
    /// ```swift
    /// let stackView = UIStackView(axis: .horizontal)
    /// ```
    convenience init(axis: NSLayoutConstraint.Axis) {
        self.init(frame: .zero)
        self.axis = axis
    }
    
    // MARK: - addArrangedSubviews

    /// `arrangedSubviews`에 여러 개의 `UIView`를 한 번에 추가하는 메서드.
    ///
    /// - Parameter views: `UIView` 인스턴스를 가변 매개변수(`variadic parameter`)로 전달
    ///
    /// 사용 예시:
    /// ```swift
    /// let stackView = UIStackView(axis: .vertical)
    /// stackView.addArrangedSubviews(label, button, imageView)
    /// ```
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { view in
            addArrangedSubview(view)
        }
    }
}
