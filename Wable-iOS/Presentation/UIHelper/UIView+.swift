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

    /// `UIView`의 특정 모서리에 `cornerRadius`를 적용하기 위한 옵션을 정의하는 `Corner` 열거형.
    ///
    /// - `topLeft`: 좌측 상단 모서리
    /// - `topRight`: 우측 상단 모서리
    /// - `bottomLeft`: 좌측 하단 모서리
    /// - `bottomRight`: 우측 하단 모서리
    /// - `top`: 상단 모서리 (좌측 상단, 우측 상단)
    /// - `bottom`: 하단 모서리 (좌측 하단, 우측 하단)
    /// - `left`: 좌측 모서리 (좌측 상단, 좌측 하단)
    /// - `right`: 우측 모서리 (우측 상단, 우측 하단)
    /// - `all`: 모든 모서리
    enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case top
        case bottom
        case left
        case right
        case all
    }
    
    /// 지정한 `Corner`에 `cornerRadius`를 적용합니다.
    ///
    /// - Parameters:
    ///   - corners: `Corner` 배열로 적용할 모서리 지정
    ///   - radius: `cornerRadius` 값
    ///
    /// 사용 예시:
    /// ```swift
    /// let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    /// view.backgroundColor = .red
    ///
    /// // 좌측 상단, 우측 상단 모서리만 둥글게 처리
    /// view.roundCorners([.topLeft, .topRight], radius: 10)
    /// ```
    func roundCorners(_ corners: [Corner], radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        
        var cornerMask: CACornerMask = []
        
        for corner in corners {
            switch corner {
            case .topLeft:
                cornerMask.insert(.layerMinXMinYCorner)
            case .topRight:
                cornerMask.insert(.layerMaxXMinYCorner)
            case .bottomLeft:
                cornerMask.insert(.layerMinXMaxYCorner)
            case .bottomRight:
                cornerMask.insert(.layerMaxXMaxYCorner)
            case .top:
                cornerMask.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner])
            case .bottom:
                cornerMask.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            case .left:
                cornerMask.formUnion([.layerMinXMinYCorner, .layerMinXMaxYCorner])
            case .right:
                cornerMask.formUnion([.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
            case .all:
                cornerMask.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                      .layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            }
        }
        
        layer.maskedCorners = cornerMask
    }
}
