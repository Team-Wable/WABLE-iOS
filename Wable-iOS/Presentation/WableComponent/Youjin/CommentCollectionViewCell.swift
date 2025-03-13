//
//  CommentCollectionViewCell.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/13/25.
//


import UIKit

import Kingfisher

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
/// cell.configureCell(info: commentInfo, commentType: .ripple, postType: .others)
/// return cell
/// ```
final class CommentCollectionViewCell: UICollectionViewCell {
    
    // MARK: Property
    
    private let type: CommentType = .ripple
    private let infoView: PostUserInfoView = PostUserInfoView()
    
    private let contentLabel: UILabel = UILabel().then {
        $0.textColor = .gray800
        $0.numberOfLines = 0
    }
    
    private let blindImageView: UIImageView = UIImageView(image: .imgReplyIsBlind).then {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var likeButton = LikeButton()
    private lazy var commentButton = CommentButton()
    private lazy var ghostButton = GhostButton()
    
    // MARK: Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup

    private func setupView() {
        addSubviews(
            infoView,
            ghostButton,
            contentLabel,
            likeButton,
            commentButton
        )
    }
    
    private func setupConstraint() {
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
        
        commentButton.snp.makeConstraints {
            $0.leading.equalTo(likeButton.snp.trailing).offset(8)
            $0.centerY.equalTo(ghostButton)
        }
    }
    
    private func setupAction() {
        ghostButton.addTarget(self, action: #selector(ghostButtonDidTap), for: .touchUpInside)
        infoView.settingButton.addTarget(self, action: #selector(settingButtonDidTap), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(replyButtonDidTap), for: .touchUpInside)
        infoView.profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(profileImageViewDidTap)
            )
        )
    }
}

// MARK: - Extension

extension CommentCollectionViewCell {
    /// 댓글 셀 구성 메서드
    /// - Parameters:
    ///   - info: 댓글 정보
    ///   - commentType: 댓글 타입 (.ripple 또는 .reply)
    ///   - postType: 게시물 타입 (.mine 또는 .others)
    func configureCell(info: CommentInfo, commentType: CommentType, postType: ContentType) {
        guard let profileURL = info.author.profileURL,
              let fanTeam = info.author.fanTeam,
              let createdDate = info.createdDate else {
                  return
              }
        
        switch postType {
        case .mine:
            ghostButton.isHidden = true
        case .others:
            ghostButton.isHidden = false
        }
        
        switch commentType {
        case .ripple:
            contentLabel.attributedText = info.text.pretendardString(with: .body4)
            commentButton.isHidden = false
        case .reply:
            infoView.snp.updateConstraints {
                $0.leading.equalToSuperview().offset(36)
            }
            
            commentButton.isHidden = true
        }
        
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
        
        contentLabel.attributedText = info.text.pretendardString(with: .body4)
        
        infoView.configureView(
            userProfileURL: profileURL,
            userName: info.author.nickname,
            userFanTeam: fanTeam,
            opacity: info.opacity.displayedValue,
            createdDate: createdDate,
            postType: .comment
        )
        commentButton.configureButton(commentCount: 0, type: .comment)
        likeButton.configureButton(
            isLiked: info.like.status,
            likeCount: info.like.count,
            postType: .comment
        )
    }
}

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
    
    @objc func profileImageViewDidTap() {
        // TODO: 프로필 이동 로직 구현 필요
        
        WableLogger.log("profileImageViewDidTap", for: .debug)
    }
    
    @objc func settingButtonDidTap() {
        // TODO: 바텀시트 올라오는 로직 구현 필요
        
        WableLogger.log("settingButtonDidTap", for: .debug)
    }
    
    @objc func ghostButtonDidTap() {
        // TODO: 내리기 로직 구현 필요
        
        WableLogger.log("ghostButtonDidTap", for: .debug)
    }
    
    @objc func replyButtonDidTap() {
        // TODO: 상세 화면으로 이동 로직 구현 필요
        
        WableLogger.log("replyButtonDidTap", for: .debug)
    }
}
