//
//  ToastView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//

import UIKit

// MARK: - Toast Types

/// 토스트 메시지 타입을 정의하는 `ToastType` 열거형.
///
/// - `loading`: 로딩 중 상태를 나타내는 토스트
/// - `complete`: 작업 완료를 나타내는 토스트
/// - `caution`: 경고를 나타내는 토스트
/// - `error`: 오류 상태를 나타내는 토스트
enum ToastType {
    case loading
    case complete
    case caution
    case error
}

/// 앱 내 간단한 알림을 표시하기 위한 토스트 뷰 클래스.
/// 상단에 표시되며 2초 후 자동으로 사라집니다.
///
/// 사용 예시:
/// ```
/// // 성공 메시지 표시
/// let toast = ToastView(status: .complete, message: "저장되었습니다")
/// toast.show()
///
/// // 오류 메시지 표시
/// ToastView(status: .error, message: "네트워크 연결이 불안정합니다").show()
/// ```
final class ToastView: UIView {
    
    // MARK: Property
    
    private let status: ToastType
    private let message: String
    
    // MARK: UIComponent
    
    private let statusImageView: UIImageView = UIImageView()
    
    private let statusLabel: UILabel = UILabel().then {
        $0.textColor = .wableBlack
        $0.numberOfLines = 2
    }
    
    /// 토스트 뷰 초기화
    /// - Parameters:
    ///   - status: 토스트 타입(.loading, .complete, .caution, .error)
    ///   - message: 표시할 메시지 텍스트
    init(status: ToastType, message: String) {
        self.status = status
        self.message = message
        
        super.init(frame: .zero)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Extension

private extension ToastView {
    
    // MARK: - Setup

    func setupView() {
        backgroundColor = .wableWhite
        addSubviews(statusImageView, statusLabel)
        roundCorners([.all], radius: 8)
        configureToast()
        configureShadow()
    }
    
    func setupConstraint() {
        statusImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.adjustedWidthEqualTo(32)
            $0.adjustedHeightEqualTo(32)
        }
        
        statusLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.leading.equalTo(statusImageView.snp.trailing).offset(6)
        }
    }
}

// MARK: - Private Configure Extension

private extension ToastView {
    func configureToast() {
        let image: UIImage = {
            switch status {
            case .loading:
                return .icLoading
            case .complete:
                return .icComplete
            case .caution:
                return .icCaution
            case .error:
                return .icError
            }
        }()
        
        statusImageView.image = image
        statusLabel.attributedText = message.pretendardString(with: .body3)
    }
    
    func configureShadow() {
        layer.do {
            $0.masksToBounds = false
            $0.shadowColor = UIColor.wableBlack.cgColor
            $0.shadowOffset = CGSize(width: 0, height: 4)
            $0.shadowRadius = 4
            $0.shadowOpacity = 0.12
        }
    }
}

// MARK: - Public Methods

extension ToastView {
    /// 토스트 메시지를 화면에 표시합니다.
    /// 2초 후에 페이드 아웃되어 자동으로 사라집니다.
    ///
    /// 사용 예시:
    /// ```
    /// let toast = ToastView(status: .complete, message: "완료되었습니다")
    /// toast.show()
    /// ```
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            return
        }
        
        window.addSubview(self)
        
        self.snp.makeConstraints {
            $0.top.equalToSuperview().offset(76)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(48.adjustedHeight)
        }
        
        animate()
    }
    
    /// 토스트 애니메이션 설정
    /// 2초 지연 후 1초 동안 페이드 아웃
    private func animate() {
        UIView.animate(withDuration: 1, delay: 2, options: .curveEaseIn) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
