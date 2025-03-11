//
//  GhostButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//


import UIKit

enum GhostButtonType {
    case large
    case small
}

enum GhostButtonStatus {
    case normal
    case disabled
}

final class GhostButton: UIButton {
    
    // MARK: Property
    
    private let type: GhostButtonType
    private let status: GhostButtonStatus
    
    // MARK: - LifeCycle
    
    init(type: GhostButtonType, status: GhostButtonStatus) {
        self.type = type
        self.status = status
        
        super.init(frame: .zero)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        configureButton()
    }
    
    private func setupConstraint() {
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

// MARK: - Extension

private extension GhostButton {
    func configureButton() {
        var configuration = UIButton.Configuration.filled()
        self.layer.cornerRadius = 16
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
            configuration.baseBackgroundColor = .gray100
            self.isUserInteractionEnabled = false
        }
        
        self.configuration = configuration
    }
}
