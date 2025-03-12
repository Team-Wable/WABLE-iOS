//
//  LikeButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

enum PostType {
    case content
    case comment
}

final class LikeButton: UIButton {
    
    // MARK: Property
    
    private var likeCount: Int = 0
    private var isLiked: Bool = false
    private var postType: PostType = .content
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraint()
        setupAction()
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
    
    private func setupAction() {
        addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Extension

extension LikeButton {
    func configureButton(isLiked: Bool, likeCount: Int, postType: PostType) {
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.postType = postType
        
        var configuration = UIButton.Configuration.plain()
        var image = UIImage()
        
        switch postType {
        case .content:
            image = self.isLiked ? .icHeartPress : .icHeartDefault
            configuration.baseForegroundColor = .wableBlack
        case .comment:
            image = self.isLiked ? .icHeartPressSmall : .icHeartGray
            configuration.baseForegroundColor = .gray600
        }
        
        configuration.image = image.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        configuration.imagePadding = 4
        configuration.attributedTitle = String(likeCount).pretendardString(with: .caption1)
        
        self.configuration = configuration
    }
}

private extension LikeButton {
    @objc func likeButtonDidTap() {
        isLiked ? (likeCount -= 1) : (likeCount += 1)
        isLiked.toggle()
        
        configureButton(isLiked: isLiked, likeCount: likeCount, postType: postType)
    }
}
