//
//  CommentButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

/// 댓글 버튼을 구현한 커스텀 UIButton 클래스.
/// 게시글에서는 댓글 수를 표시하고, 댓글에서는 '답글쓰기' 텍스트를 표시합니다.
///
/// 사용 예시:
/// ```swift
/// let commentButton = CommentButton()
/// // 게시글용 댓글 버튼 구성
/// commentButton.configureButton(commentCount: 12, type: .content)
/// // 또는 답글 버튼 구성
/// commentButton.configureButton(commentCount: 0, type: .comment)
/// ```
final class CommentButton: UIButton {
    
    // MARK: Property

    /// 버튼이 속한 게시물 타입 (게시글/댓글)
    private var type: PostType
    
    // MARK: - LifeCycle
    
    init(type: PostType) {
        self.type = type
        
        super.init(frame: .zero)
        
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Extension

private extension CommentButton {
    
    // MARK: - Setup
    
    func setupConstraint() {
        snp.makeConstraints {
            $0.adjustedWidthEqualTo(45)
            $0.adjustedHeightEqualTo(24)
        }
    }
}

// MARK: - Configure Extension

extension CommentButton {
    /// 댓글 버튼 구성 메서드
    /// - Parameters:
    ///   - commentCount: 댓글 수 (게시글 타입일 때만 사용)
    ///   - type: 버튼이 속한 게시물 타입 (.content 또는 .comment)
    func configureButton(commentCount: Int = 0) {
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
