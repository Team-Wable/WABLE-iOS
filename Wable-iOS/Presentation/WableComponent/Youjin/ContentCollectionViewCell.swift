//
//  ContentCollectionViewCell.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

enum ContentType {
    case mine
    case others
}

final class ContentCollectionViewCell: UICollectionViewCell {
    
    // MARK: Property
    
    private let infoView: PostUserInfoView = PostUserInfoView()
    
    private let contentStackView: UIStackView = UIStackView(axis: .vertical).then {
        $0.spacing = 10
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    private let titleLabel: UILabel = UILabel().then {
        $0.textColor = .wableBlack
        $0.numberOfLines = 0
    }
    
    private let contentImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.roundCorners([.all], radius: 8)
    }
    
    private let contentLabel: UILabel = UILabel().then {
        $0.textColor = .gray800
        $0.numberOfLines = 0
    }
    
    private lazy var ghostButton: GhostButton = GhostButton()
    
    private lazy var likeButton: LikeButton = LikeButton()
    
    private lazy var commentButton: CommentButton = CommentButton()
    
    private let divideView: UIView = UIView().then {
        $0.backgroundColor = .gray200
    }
    
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
        contentStackView.addArrangedSubviews(
            titleLabel,
            contentImageView,
            contentLabel
        )
        
        contentView.addSubviews(
            infoView,
            contentStackView,
            ghostButton,
            likeButton,
            commentButton,
            divideView
        )
    }
    
    private func setupConstraint() {
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.horizontalEdges.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        contentImageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.adjustedHeightEqualTo(192)
        }
        
        ghostButton.snp.makeConstraints {
            $0.top.equalTo(contentStackView.snp.bottom).offset(20)
            $0.leading.equalTo(infoView).offset(16)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        likeButton.snp.makeConstraints {
            $0.centerY.equalTo(ghostButton)
            $0.trailing.equalTo(commentButton.snp.leading).offset(-16)
        }
        
        commentButton.snp.makeConstraints {
            $0.centerY.equalTo(ghostButton)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        divideView.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
            $0.adjustedHeightEqualTo(1)
        }
    }
    
    private func setupAction() {
        ghostButton.addTarget(self, action: #selector(ghostButtonDidTap), for: .touchUpInside)
        infoView.settingButton.addTarget(self, action: #selector(settingButtonDidTap), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentButtonDidTap), for: .touchUpInside)
        infoView.profileImageView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(profileImageViewDidTap)
            )
        )
    }
}

// MARK: - Extension

extension ContentCollectionViewCell {
    func configureCell(info: ContentInfo, type: ContentType) {
        guard let profileURL = info.author.profileURL,
        let fanTeam = info.author.fanTeam,
        let createdDate = info.createdDate else {
            return
        }
        
        infoView.configureView(
            userProfileURL: profileURL,
            userName: info.author.nickname,
            userFanTeam: fanTeam,
            opacity: info.opacity.displayedValue,
            createdDate: createdDate
        )
    
        titleLabel.attributedText = info.title.pretendardString(with: .head2)
        contentLabel.attributedText = info.text.pretendardString(with: .body4)
        contentImageView.kf.setImage(with: info.imageURL)
        
        ghostButton.configureButton(type: .large, status: .normal)
        likeButton.configureButton(isLiked: info.like.status, likeCount: info.like.count)
        commentButton.configureButton(commentCount: info.commentCount)
        
        switch type {
        case .mine:
            ghostButton.isHidden = true
        case .others:
            break
        }
        
        switch info.status {
        case .normal:
            ghostCell(opacity: info.opacity.alpha)
        case .ghost:
            ghostCell(opacity: 0.15)
            ghostButton.configureButton(type: .large, status: .disabled)
        case .blind:
            DispatchQueue.main.async {
                self.contentImageView.image = .imgFeedIsBlind
            }
            
            titleLabel.isHidden = true
            contentLabel.isHidden = true
            contentImageView.snp.updateConstraints {
                $0.adjustedHeightEqualTo(98)
            }
        }
    }
}

private extension ContentCollectionViewCell {
    func ghostCell(opacity: Float) {
        [
            infoView,
            contentImageView,
            titleLabel,
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
    
    @objc func commentButtonDidTap() {
        // TODO: 상세 화면으로 이동 로직 구현 필요
        
        WableLogger.log("commentButtonDidTap", for: .debug)
    }
}
