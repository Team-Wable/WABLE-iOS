//
//  LikeButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

final class CommentButton: UIButton {
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupConstraint() {
        snp.makeConstraints {
            $0.adjustedWidthEqualTo(45)
            $0.adjustedHeightEqualTo(24)
        }
    }
}

// MARK: - Extension

extension CommentButton {
    func configureButton(commentCount: Int) {
        var configuration = UIButton.Configuration.plain()
        
        configuration.image = .icRipple.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        configuration.imagePadding = 4
        configuration.attributedTitle = String(commentCount).pretendardString(with: .caption1)
        configuration.baseForegroundColor = .wableBlack
        
        self.configuration = configuration
    }
}
