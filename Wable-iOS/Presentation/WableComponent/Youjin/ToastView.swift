//
//  ToastView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//


import UIKit

enum ToastType {
    case loading
    case complete
    case caution
    case error
}

final class ToastView: UIView {
    
    // MARK: Property
    
    private let status: ToastType
    private let message: String
    private let statusImageView: UIImageView = UIImageView()
    private let statusLabel: UILabel = UILabel().then {
        $0.textColor = .wableBlack
        $0.numberOfLines = 2
    }
    
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
    
    // MARK: - Setup

    private func setupView() {
        backgroundColor = .wableWhite
        addSubviews(statusImageView, statusLabel)
        roundCorners([.all], radius: 8)
        configureToast()
        configureShadow()
    }
    
    private func setupConstraint() {
        statusImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.widthEqualTo(32)
            $0.heightEqualTo(32)
        }
        
        statusLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.leading.equalTo(statusImageView.snp.trailing).offset(6)
        }
    }
}

// MARK: - Extension

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

extension ToastView {
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return }
        
        window.addSubview(self)
        
        self.snp.makeConstraints {
            $0.top.equalToSuperview().offset(76)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(48.adjustedHeight)
        }
        
        animate()
    }
    
    private func animate() {
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseIn) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
