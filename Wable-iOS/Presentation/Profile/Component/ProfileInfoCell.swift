//
//  ProfileInfoCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

import SnapKit
import Then
import Kingfisher

final class ProfileInfoCell: UICollectionViewCell {
    
    // MARK: - Property
    
    private var editButtonTapHandler: VoidClosure?

    // MARK: - Header UIComponent

    private let headerView = UIView()
    
    private let profileImageView = UIImageView(image: .imgProfileGreen).then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = Constant.profileImageViewSize / 2
        $0.clipsToBounds = true
    }
    
    private let levelLabel = UILabel().then {
        $0.attributedText = "LV. 1".pretendardString(with: .caption1)
        $0.textColor = .gray600
    }
    
    private let nicknameLabel = UILabel().then {
        $0.attributedText = "닉네임".pretendardString(with: .head2)
    }
    
    private let editButton = UIButton().then {
        $0.setImage(.icEdit, for: .normal)
    }
    
    // MARK: - Introduction UIComponent
    
    private let introductionView = UIView(backgroundColor: .gray100).then {
        $0.layer.cornerRadius = 8
    }

    private let introductionLabel = UILabel().then {
        $0.attributedText = "소개".pretendardString(with: .body4)
        $0.textColor = .gray700
        $0.numberOfLines = 0
    }
    
    // MARK: - Ghost UIComponent
    
    private let ghostView = UIView()
    
    private let ghostTitleLabel = UILabel().then {
        $0.attributedText = "투명도".pretendardString(with: .caption1)
    }
    
    private let ghostImageView = UIImageView(image: .icPurpleGhost)
    
    private let ghostValueLabel = UILabel().then {
        $0.attributedText = "50%".pretendardString(with: .body3)
    }
    
    private let ghostProgressBar = UIProgressView(progressViewStyle: .default).then {
        $0.progressTintColor = .purple50
        $0.trackTintColor = .gray200
        $0.layer.cornerRadius = 8
        $0.progress = .zero
        $0.clipsToBounds = true
    }
    
    // MARK: - Badge UIComponent

    private let badgeView = UIView()
    
    private let badgeTitleLabel = UILabel().then {
        $0.attributedText = "뱃지".pretendardString(with: .caption1)
    }
    
    private let defaultBadgeImageView = UIImageView(image: .imgBadge)

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupHeaderView()
        setupIntroductionView()
        setupGhostView()
        setupBadgeView()
        setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        isMyProfile: Bool,
        profileImageURL: URL?,
        level: String,
        nickname: String,
        introduction: String,
        ghostValue: Int,
        editButtonTapHandler: VoidClosure?
    ) {
        self.editButtonTapHandler = editButtonTapHandler
        editButton.isHidden = !isMyProfile
        
        levelLabel.text = "LV. \(level)"
        nicknameLabel.text = nickname
        introductionLabel.text = introduction
        ghostValueLabel.text = "\(ghostValue)%"
        ghostProgressBar.setProgress(Float(100 + ghostValue) / 100, animated: true)
        
        let randomProfileImage = [
            UIImage.imgProfilePurple,
            UIImage.imgProfileBlue,
            UIImage.imgProfileGreen
        ].randomElement()
        
        guard let profileImageURL,
              !profileImageURL.absoluteString.isEmpty
        else {
            profileImageView.image = randomProfileImage
            return
        }
        
        switch profileImageURL.absoluteString {
        case "PURPLE":
            profileImageView.image = .imgProfilePurple
        case "GREEN":
            profileImageView.image = .imgProfileGreen
        case "BLUE":
            profileImageView.image = .imgProfileBlue
        default:
            profileImageView.kf.setImage(with: profileImageURL, placeholder: randomProfileImage)
        }
    }
}

private extension ProfileInfoCell {
    func setupView() {
        contentView.addSubviews(headerView, introductionView, ghostView, badgeView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(introductionView.snp.top).offset(-20)
        }
        
        introductionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(headerView)
            make.bottom.equalTo(ghostView.snp.top).offset(-12)
        }
        
        ghostView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(headerView)
            make.bottom.equalTo(badgeView.snp.top).offset(-12)
        }
        
        badgeView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(headerView)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func setupHeaderView() {
        headerView.addSubviews(profileImageView, levelLabel, nicknameLabel, editButton)
        
        profileImageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.size.equalTo(Constant.profileImageViewSize)
        }
        
        levelLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(12)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(levelLabel.snp.bottom).offset(4)
            make.leading.equalTo(levelLabel)
        }
        
        editButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.trailing.equalToSuperview()
            make.size.equalTo(Constant.editButtonSize)
        }
    }
    
    func setupIntroductionView() {
        introductionView.addSubview(introductionLabel)
        
        introductionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    func setupGhostView() {
        ghostView.addSubviews(ghostTitleLabel, ghostImageView, ghostValueLabel, ghostProgressBar)
        
        ghostTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        ghostImageView.snp.makeConstraints { make in
            make.centerY.equalTo(ghostValueLabel)
            make.trailing.equalTo(ghostValueLabel.snp.leading).offset(-8)
            make.size.equalTo(Constant.ghostImageViewSize)
        }
        
        ghostValueLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.bottom.equalTo(ghostProgressBar.snp.top).offset(-4)
        }
        
        ghostProgressBar.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.adjustedHeightEqualTo(12)
        }
    }
    
    func setupBadgeView() {
        badgeView.addSubviews(badgeTitleLabel, defaultBadgeImageView)
        
        badgeTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.bottom.equalTo(defaultBadgeImageView.snp.top).offset(-4)
        }
        
        defaultBadgeImageView.snp.makeConstraints { make in
            make.leading.equalTo(badgeTitleLabel)
            make.adjustedHeightEqualTo(Constant.badgeImageViewHeight)
        }
    }
    
    func setupAction() {
        editButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            
            editButtonTapHandler?()
        }), for: .touchUpInside)
    }
    
    enum Constant {
        static let profileImageViewSize: CGFloat = 80
        static let editButtonSize: CGFloat = 48
        static let ghostImageViewSize: CGFloat = 16
        static let badgeImageViewHeight: CGFloat = 52
    }
}
