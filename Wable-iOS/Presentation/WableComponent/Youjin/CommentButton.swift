//
//  LikeButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

final class CommentButton: UIButton {
    
    // MARK: Property
    
    private var commentCount: Int
    
    // MARK: - LifeCycle
    
    init(commentCount: Int) {
        self.commentCount = commentCount
        
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
        snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(45.adjustedWidth)
            $0.adjustedHeightEqualTo(24)
        }
    }
}

// MARK: - Extension

private extension CommentButton {
    func configureButton() {
        var configuration = UIButton.Configuration.plain()
        
        configuration.image = .icRipple
        configuration.imagePadding = 4
        configuration.title = String(commentCount)
        configuration.baseForegroundColor = .wableBlack
        
        self.configuration = configuration
    }
}
