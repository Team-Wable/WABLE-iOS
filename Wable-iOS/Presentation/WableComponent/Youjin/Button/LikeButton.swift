//
//  LikeButton.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

/// 게시물 타입을 정의하는 열거형.
///
/// - `content`: 게시글 타입
/// - `comment`: 댓글 타입
enum PostType {
    case content
    case comment
}

/// 좋아요 버튼을 구현한 커스텀 UIButton 클래스.
/// 버튼의 상태(좋아요 여부)와 좋아요 수를 표시합니다.
///
/// 사용 예시:
/// ```swift
/// let likeButton = LikeButton()
/// likeButton.configureButton(isLiked: false, likeCount: 5, postType: .content)
/// containerView.addSubview(likeButton)
/// ```
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
}

// MARK: - Private Extension

private extension LikeButton {
    
    // MARK: - Setup

    func setupConstraint() {
        snp.makeConstraints {
            $0.adjustedWidthEqualTo(45)
            $0.adjustedHeightEqualTo(24)
        }
    }
    
    func setupAction() {
        addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - @objc method

    @objc func likeButtonDidTap() {
        isLiked ? (likeCount -= 1) : (likeCount += 1)
        isLiked.toggle()
        
        configureButton(isLiked: isLiked, likeCount: likeCount, postType: postType)
    }
}

// MARK: - Configure Extension

extension LikeButton {
    /// 좋아요 버튼 구성 메서드
    /// - Parameters:
    ///   - isLiked: 좋아요 눌렀는지 여부
    ///   - likeCount: 좋아요 수
    ///   - postType: 버튼이 속한 게시물 타입 (.content 또는 .comment)
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
