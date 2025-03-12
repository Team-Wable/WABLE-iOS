//
//  LikeButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

final class CommentButton: UIButton {
    
    // MARK: Property

    private var type: PostType = .content
    
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
    func configureButton(commentCount: Int, type: PostType) {
        self.type = type
        
        var configuration = UIButton.Configuration.plain()
        var image = UIImage()
        
        switch type {
        case .content:
            image = .icRipple
            
            configuration.attributedTitle = String(commentCount).pretendardString(with: .caption1)
            configuration.baseForegroundColor = .wableBlack
        case .comment:
            image = .icRippleReply
            
            configuration.attributedTitle = "답글쓰기".pretendardString(with: .caption3)
            configuration.baseForegroundColor = .gray600

            snp.makeConstraints {
                $0.adjustedWidthEqualTo(66)
                $0.adjustedHeightEqualTo(20)
            }
            
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
        
        configuration.image = image.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        configuration.imagePadding = 4
        
        self.configuration = configuration
    }
}
