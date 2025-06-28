//
//  ProfileInfoCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
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
    
    private let levelBadgeImageView = UIImageView(image: .icLevelBadge).then {
        $0.contentMode = .scaleAspectFit
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
    
    // MARK: - Footer UIComponent
    
    private let footerView = UIView()
    
    private let ghostTitleLabel = UILabel().then {
        $0.attributedText = "투명도".pretendardString(with: .caption1)
    }
    
    private let ghostInfoButton = UIButton().then {
        $0.setImage(.icGhostInfo, for: .normal)
    }
    
    private let ghostInfoTooltip = GhostInfoTooltipView().then {
        $0.isHidden = true
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
    
    private let badgeTitleLabel = UILabel().then {
        $0.attributedText = "뱃지".pretendardString(with: .caption1)
    }
    
    private let defaultBadgeImageView = UIImageView(image: .imgBadge).then {
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Property
    
    private var tooltipTimer: AnyCancellable?
    
    private let cancelBag = CancelBag()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupHeaderView()
        setupIntroductionView()
        setupFooterView()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.ghostProgressBar.setProgress(Float(100 + ghostValue) / 100, animated: true)
        }
        
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
        contentView.addSubviews(headerView, introductionView, footerView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(introductionView.snp.top).offset(-20)
        }
        
        introductionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(headerView)
            make.bottom.equalTo(footerView.snp.top).offset(-12)
        }
        
        footerView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(headerView)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func setupHeaderView() {
        headerView.addSubviews(profileImageView, levelBadgeImageView, levelLabel, nicknameLabel, editButton)
        
        profileImageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.size.equalTo(Constant.profileImageViewSize)
        }
        
        levelBadgeImageView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(12)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.size.equalTo(16)
        }
        
        levelLabel.snp.makeConstraints { make in
            make.centerY.equalTo(levelBadgeImageView)
            make.leading.equalTo(levelBadgeImageView.snp.trailing).offset(4)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(levelBadgeImageView.snp.bottom).offset(4)
            make.leading.equalTo(levelBadgeImageView)
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
    
    func setupFooterView() {
        footerView.addSubviews(
            ghostTitleLabel,
            ghostInfoButton,
            ghostImageView,
            ghostValueLabel,
            ghostProgressBar,
            ghostInfoTooltip,
            badgeTitleLabel,
            defaultBadgeImageView
        )
        
        footerView.bringSubviewToFront(ghostInfoTooltip)
        
        ghostTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        ghostInfoButton.snp.makeConstraints { make in
            make.centerY.equalTo(ghostTitleLabel)
            make.leading.equalTo(ghostTitleLabel.snp.trailing).offset(4)
            make.size.equalTo(12)
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
            make.horizontalEdges.equalToSuperview()
            make.adjustedHeightEqualTo(12)
        }
        
        ghostInfoTooltip.snp.makeConstraints { make in
            make.top.equalTo(ghostProgressBar.snp.bottom).offset(4)
            make.leading.equalTo(ghostProgressBar)
            make.trailing.equalToSuperview()
        }
        
        badgeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(ghostProgressBar.snp.bottom).offset(12)
            make.leading.equalTo(ghostInfoTooltip)
            make.bottom.equalTo(defaultBadgeImageView.snp.top).offset(-4)
        }
        
        defaultBadgeImageView.snp.makeConstraints { make in
            make.leading.equalTo(badgeTitleLabel)
            make.adjustedHeightEqualTo(Constant.badgeImageViewHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    func setupAction() {
        editButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.editButtonTapHandler?()
            }
            .store(in: cancelBag)
        
        let onGhostTitleTap = ghostTitleLabel.gesture().asVoid()
        let onGhostInfoTap = ghostInfoButton.publisher(for: .touchUpInside)
        Publishers.Merge(onGhostTitleTap, onGhostInfoTap)
            .sink { [weak self] _ in
                self?.toggleTooltip()
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Helper Method
    
    func toggleTooltip() {
        tooltipTimer?.cancel()
        
        if ghostInfoTooltip.isHidden {
            showTooltipWithAnimation()
            
            tooltipTimer = Just(())
                .delay(for: .seconds(5), scheduler: DispatchQueue.main)
                .sink { [weak self] _ in self?.hideTooltipWithAnimation() }
        } else {
            hideTooltipWithAnimation()
        }
    }
    
    func showTooltipWithAnimation() {
        ghostInfoTooltip.alpha = 0
        ghostInfoTooltip.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        ghostInfoTooltip.isHidden = false
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.2
        ) {
            self.ghostInfoTooltip.alpha = 1
            self.ghostInfoTooltip.transform = .identity
        }
    }
    
    func hideTooltipWithAnimation() {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            self.ghostInfoTooltip.alpha = 0
            self.ghostInfoTooltip.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.ghostInfoTooltip.isHidden = true
            self.ghostInfoTooltip.transform = .identity
        }
    }
    
    // MARK: - Constant
    
    enum Constant {
        static let profileImageViewSize: CGFloat = 80
        static let editButtonSize: CGFloat = 48
        static let ghostImageViewSize: CGFloat = 16
        static let badgeImageViewHeight: CGFloat = 52
    }
}
