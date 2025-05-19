//
//  CommentCollectionViewCell.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/13/25.
//


import UIKit

import Kingfisher

// MARK: - Enum

/// 댓글 타입을 정의하는 열거형.
///
/// - `ripple`: 게시글에 직접 달린 댓글
/// - `reply`: 다른 댓글에 달린 답글
enum CommentType {
    case ripple
    case reply
}

/// 댓글을 표시하기 위한 컬렉션 뷰 셀.
/// 사용자 정보, 댓글 내용, 좋아요/답글/내리기 버튼 등을 포함합니다.
///
/// 사용 예시:
/// ```swift
/// collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: CommentCollectionViewCell.reuseIdentifier)
///
/// // cellForItemAt에서:
/// let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.reuseIdentifier, for: indexPath) as! CommentCollectionViewCell
/// cell.configureCell(info: commentInfo, commentType: .ripple, authorType: .others)
/// return cell
/// ```
final class CommentCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Property
    
    var likeButtonTapHandler: (() -> Void)?
    var profileImageViewTapHandler: (() -> Void)?
    var settingButtonTapHandler: (() -> Void)?
    var ghostButtonTapHandler: (() -> Void)?
    var replyButtonTapHandler: (() -> Void)?
    
    // MARK: - UIComponent
    
    let infoView: PostUserInfoView = PostUserInfoView()
    
    private let contentLabel: UILabel = UILabel().then {
        $0.textColor = .gray800
        $0.numberOfLines = 0
    }
    
    private let blindImageView: UIImageView = UIImageView(image: .imgReplyIsBlind).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let divisionLine: UIView = UIView().then {
        $0.backgroundColor = .gray200
    }
    
    lazy var likeButton = LikeButton()
    private lazy var replyButton = CommentButton(type: .comment)
    private lazy var ghostButton = GhostButton()
    
    // MARK: - LifeCycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Extension

private extension CommentCollectionViewCell {
    
    // MARK: - Setup

    func setupView() {
        contentView.addSubviews(
            infoView,
            ghostButton,
            contentLabel,
            likeButton,
            replyButton,
            divisionLine
        )
    }
    
    func setupConstraint() {
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.trailing.equalToSuperview()
        }
        
        ghostButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(17.5)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        likeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(52)
            $0.centerY.equalTo(ghostButton)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(4)
            $0.leading.equalTo(likeButton)
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(ghostButton.snp.top).offset(-12)
        }
        
        replyButton.snp.makeConstraints {
            $0.leading.equalTo(likeButton.snp.trailing).offset(8)
            $0.centerY.equalTo(ghostButton)
        }
        
        divisionLine.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func setupAction() {
        replyButton.addTarget(self, action: #selector(replyButtonDidTap), for: .touchUpInside)
        ghostButton.addTarget(self, action: #selector(ghostButtonDidTap), for: .touchUpInside)
        infoView.settingButton.addTarget(self, action: #selector(settingButtonDidTap), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
        infoView.profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(profileImageViewDidTap)
            )
        )
    }
}

// MARK: - @objc method

private extension CommentCollectionViewCell {
    @objc func profileImageViewDidTap() {
        profileImageViewTapHandler?()
    }
    
    @objc func settingButtonDidTap() {
        settingButtonTapHandler?()
    }
    
    @objc func ghostButtonDidTap() {
        ghostButtonTapHandler?()
    }
    
    @objc func replyButtonDidTap() {
        replyButtonTapHandler?()
    }
    
    @objc func likeButtonDidTap() {
        let newCount = likeButton.isLiked ? likeButton.likeCount - 1 : likeButton.likeCount + 1
        
        likeButton.configureButton(isLiked: !likeButton.isLiked, likeCount: newCount, postType: .comment)
        
        self.likeButtonTapHandler?()
    }
}

// MARK: - Helper Method

private extension CommentCollectionViewCell {
    /// 셀 투명도 설정
    /// - Parameter opacity: 투명도 값 (0.0 ~ 1.0)
    func ghostCell(opacity: Float) {
        [
            infoView,
            contentLabel
        ].forEach {
            $0.alpha = CGFloat(opacity)
        }
    }
}


// MARK: - Configure Method

extension CommentCollectionViewCell {
    /// 댓글 셀 구성 메서드
    /// - Parameters:
    ///   - info: 댓글 정보
    ///   - commentType: 댓글 타입 (.ripple 또는 .reply)
    ///   - authorType: 게시물 타입 (.mine 또는 .others)
    ///   - likeButtonTapHandler: 좋아요 버튼을 클릭했을 때 실행될 로직
    ///   - replyButtonTapHandler: 답글쓰기 버튼을 클릭했을 때 실행될 로직
    func configureCell(
        info: CommentInfo,
        commentType: CommentType,
        authorType: AuthorType,
        likeButtonTapHandler: (() -> Void)?,
        settingButtonTapHandler: (() -> Void)?,
        profileImageViewTapHandler: (() -> Void)?,
        ghostButtonTapHandler: (() -> Void)?,
        replyButtonTapHandler: (() -> Void)?
    ) {
        self.likeButtonTapHandler = likeButtonTapHandler
        self.ghostButtonTapHandler = ghostButtonTapHandler
        self.profileImageViewTapHandler = profileImageViewTapHandler
        self.settingButtonTapHandler = settingButtonTapHandler
        self.replyButtonTapHandler = replyButtonTapHandler
        
        guard let createdDate = info.createdDate else { return }
        
        ghostButton.isHidden = authorType == .mine || info.status == .ghost
        configureCommentType(info: info, commentType: commentType)
        configurePostStatus(info: info)
        
        contentLabel.attributedText = info.text.pretendardString(with: .body4)
        
        infoView.configureView(
            userProfileURL: info.author.profileURL,
            userName: info.author.nickname,
            userFanTeam: info.author.fanTeam,
            opacity: info.opacity.displayedValue,
            createdDate: createdDate,
            postType: .comment
        )
        
        replyButton.configureButton()
        likeButton.configureButton(
            isLiked: info.like.status,
            likeCount: info.like.count,
            postType: .comment
        )
    }
    
    func configureCommentType(info: CommentInfo, commentType: CommentType) {
        contentLabel.attributedText = info.text.pretendardString(with: .body4)
        
        switch commentType {
        case .ripple:
            replyButton.isHidden = false
        case .reply:
            infoView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(36)
            }
            
            replyButton.isHidden = true
        }
    }
    
    func configurePostStatus(info: CommentInfo) {
        switch info.status {
        case .normal:
            ghostCell(opacity: info.opacity.alpha)
            ghostButton.configureButton(type: .small, status: .normal)
        case .ghost:
            ghostCell(opacity: 0.15)
            ghostButton.configureButton(type: .large, status: .disabled)
        case .blind:
            ghostCell(opacity: info.opacity.alpha)
            contentLabel.removeFromSuperview()
            addSubview(blindImageView)
            
            blindImageView.snp.makeConstraints {
                $0.top.equalTo(infoView.snp.bottom).offset(12)
                $0.leading.equalTo(likeButton)
                $0.trailing.equalTo(ghostButton)
                $0.bottom.equalTo(ghostButton.snp.top).offset(-12)
                $0.adjustedHeightEqualTo(50)
            }
            
            ghostButton.configureButton(type: .small, status: .normal)
        }
    }
}
