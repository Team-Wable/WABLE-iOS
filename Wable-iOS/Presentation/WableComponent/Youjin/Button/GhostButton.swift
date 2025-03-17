//
//  GhostButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//


import UIKit

/// 내리기 버튼의 크기 타입을 정의하는 열거형.
///
/// - `large`: 텍스트를 포함한 큰 버튼 (71x32)
/// - `small`: 아이콘만 있는 작은 버튼 (32x32)
enum GhostButtonType {
    case large
    case small
}

/// 내리기 버튼의 상태를 정의하는 열거형.
///
/// - `normal`: 정상 상태 (클릭 가능)
/// - `disabled`: 비활성화 상태 (클릭 불가)
enum GhostButtonStatus {
    case normal
    case disabled
}

/// 게시물의 투명도를 낮추는 기능을 하는 내리기 버튼 클래스.
/// 두 가지 크기(large/small)와 두 가지 상태(normal/disabled)를 지원합니다.
///
/// 사용 예시:
/// ```swift
/// let ghostButton = GhostButton()
/// // 큰 버튼 구성
/// ghostButton.configureButton(type: .large, status: .normal)
/// // 또는 작은 버튼 구성
/// ghostButton.configureButton(type: .small, status: .disabled)
/// ```
final class GhostButton: UIButton { }

// MARK: - Private Extension

private extension GhostButton {
    
    // MARK: - Setup
    
    /// - Parameter type: 버튼 크기 타입
    func setupConstraint(type: GhostButtonType) {
        switch type {
        case .large:
            snp.makeConstraints {
                $0.adjustedWidthEqualTo(71)
                $0.adjustedHeightEqualTo(32)
            }
        case .small:
            snp.makeConstraints {
                $0.adjustedWidthEqualTo(32)
                $0.adjustedHeightEqualTo(32)
            }
        }
    }
}

// MARK: - Configure Extension

extension GhostButton {
    /// 내리기 버튼 구성 메서드
    /// - Parameters:
    ///   - type: 버튼 크기 타입 (.large 또는 .small)
    ///   - status: 버튼 상태 (.normal 또는 .disabled)
    func configureButton(type: GhostButtonType, status: GhostButtonStatus) {
        var configuration = UIButton.Configuration.filled()
        self.roundCorners([.all], radius: 16)
        self.clipsToBounds = true
        
        switch type {
        case .large:
            configuration.attributedTitle = "내리기".pretendardString(with: .caption3)
            configuration.imagePadding = 4
            configuration.imagePlacement = .leading
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        case .small:
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        }
        
        switch status {
        case .normal:
            configuration.attributedTitle?.foregroundColor = UIColor("556480")
            configuration.image = .icGhostDefault.withTintColor(UIColor("556480"))
            configuration.baseBackgroundColor = UIColor("DDE4F1")
            self.isUserInteractionEnabled = true
        case .disabled:
            configuration.attributedTitle?.foregroundColor = UIColor("AEAEAE")
            configuration.image = .icGhostDefault.withTintColor(.gray500)
            configuration.baseBackgroundColor = UIColor("F7F7F7")
            self.isUserInteractionEnabled = false
        }
        
        self.configuration = configuration
        setupConstraint(type: type)
    }
}
