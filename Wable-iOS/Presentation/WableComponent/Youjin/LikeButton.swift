//
//  LikeButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

final class LikeButton: UIButton {
    
    // MARK: Property
    
    private var isLiked: Bool
    private var likeCount: Int
    
    // MARK: - LifeCycle
    
    init(isLiked: Bool = false, likeCount: Int) {
        self.isLiked = isLiked
        self.likeCount = likeCount
        
        super.init(frame: .zero)
        
        setupView()
        setupConstraint()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        configureButton()
    }
    
    private func setupConstraint() {
        snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(45.adjustedWidth)
            $0.adjustedHeightEqualTo(24)
        }
    }
    
    private func setupAction() {
        addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Extension

private extension LikeButton {
    func configureButton() {
        var configuration = UIButton.Configuration.plain()
        
        configuration.image = isLiked ? .icHeartPress : .icHeartDefault
        configuration.imagePadding = 4
        configuration.title = String(likeCount)
        configuration.baseForegroundColor = .wableBlack
        
        self.configuration = configuration
    }
}

private extension LikeButton {
    @objc func likeButtonDidTap() {
        isLiked ? (likeCount -= 1) : (likeCount += 1)
        isLiked.toggle()
        self.configureButton()
    }
}
