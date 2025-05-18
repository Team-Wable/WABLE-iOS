//
//  ViewitListCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ViewitListCell: UICollectionViewCell {
    
    // MARK: - Header UIComponent

    private let headerView = UIView()
    
    private let profileInfoStackView = UIStackView(axis: .horizontal).then {
        $0.spacing = 8
        $0.isUserInteractionEnabled = true
    }
    
    private let profileImageView = UIImageView(image: .imgProfilePurple).then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = Constant.profileImageViewSize / 2
        $0.clipsToBounds = true
    }
    
    private let userNameLabel = UILabel().then {
        $0.attributedText = "이름".pretendardString(with: .body3)
    }
    
    private let meatballButton = UIButton().then {
        $0.setImage(.icMeatball, for: .normal)
    }
    
    // MARK: - Description UIComponent

    private let descriptionView = UIView(backgroundColor: .purple10).then {
        $0.roundCorners([.bottom, .topRight], radius: 8)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.attributedText = "뷰잇 멘트는 최대 50자만 가능해요.".pretendardString(with: .body4)
        $0.textColor = UIColor("4a4a4a")
        $0.numberOfLines = 2
    }
    
    // MARK: - Card UIComponent

    private let cardView = UIView(backgroundColor: .gray100).then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.gray200.cgColor
        $0.layer.borderWidth = 1
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
    }
    
    private let thumbnailImageView = UIImageView(image: .imgViewitThumnail).then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.attributedText = "영상 제목".pretendardString(with: .body3)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let siteNameLabel = UILabel().then {
        $0.attributedText = "사이트 이름".pretendardString(with: .caption4)
        $0.textColor = .gray600
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let likeButton = LikeButton()
    
    // MARK: - Blind UIComponent

    private let blindImageView = UIImageView(image: .imgFeedIsBlind).then {
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    
    // MARK: - Property
    
    var profileInfoDidTapClosure: VoidClosure?
    var meatballDidTapClosure: VoidClosure?
    var cardDidTapClosure: VoidClosure?
    var likeDidTapClosure: VoidClosure?
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
        setupHeaderView()
        setupDescriptionView()
        setupCardView()
        setupAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.kf.cancelDownloadTask()
        thumbnailImageView.kf.cancelDownloadTask()
        
        profileImageView.image = .imgProfilePurple
        userNameLabel.text = "이름"
        thumbnailImageView.image = .imgViewitThumnail
        descriptionLabel.text = "설명"
        titleLabel.text = "제목"
        siteNameLabel.text = "사이트 이름"
        likeButton.configureButton(isLiked: false, likeCount: 0, postType: .content)
        
        profileInfoDidTapClosure = nil
        meatballDidTapClosure = nil
        cardDidTapClosure = nil
        likeDidTapClosure = nil
    }
    
    func configure(
        profileImageURL: URL?,
        userName: String?,
        description: String?,
        thumbnailImageURL: URL?,
        title: String?,
        siteName: String?,
        isLiked: Bool,
        likeCount: Int,
        isBlind: Bool
    ) {
        configure(isBlind: isBlind)
        configureHeaderView(profileImageURL: profileImageURL, userName: userName)
        configureDescriptionView(description: description)
        configureCardView(
            thumbnailImageURL: thumbnailImageURL,
            title: title,
            siteName: siteName,
            isLiked: isLiked,
            likeCount: likeCount
        )
    }
}

private extension ViewitListCell {
    
    // MARK: - Setup Method

    func setupCell() {
        let underlineView = UIView(backgroundColor: .gray200)
        
        let stackView = UIStackView(arrangedSubviews: [headerView, descriptionView, cardView, blindImageView]).then {
            $0.axis = .vertical
            $0.spacing = 8
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        contentView.addSubviews(stackView, underlineView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        blindImageView.snp.makeConstraints { make in
            make.adjustedHeightEqualTo(100)
        }
        
        underlineView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func setupHeaderView() {
        profileInfoStackView.addArrangedSubviews(profileImageView, userNameLabel)
        
        headerView.addSubviews(profileInfoStackView, meatballButton)
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(Constant.profileImageViewSize)
        }
        
        profileInfoStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        meatballButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
            make.size.equalTo(Constant.etcButtonSize)
        }
    }
    
    func setupDescriptionView() {
        descriptionView.addSubview(descriptionLabel)
        
        descriptionLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    func setupCardView() {
        cardView.addSubviews(thumbnailImageView, titleLabel, siteNameLabel, likeButton)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.adjustedWidthEqualTo(128)
            make.adjustedHeightEqualTo(78)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(8)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(8)
            make.bottom.equalTo(siteNameLabel.snp.top)
        }
        
        siteNameLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(titleLabel)
            make.bottom.lessThanOrEqualTo(likeButton.snp.top).offset(0)
        }
        
        likeButton.snp.makeConstraints { make in
            make.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-4)
        }
    }
    
    func setupAction() {
        profileInfoStackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(profileInfoDidTap))
        )
        
        meatballButton.addTarget(self, action: #selector(meatBallDidTap), for: .touchUpInside)
        
        cardView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(cardDidTap))
        )
        
        likeButton.addTarget(self, action: #selector(likeDidTap), for: .touchUpInside)
    }
    
    // MARK: - Helper Method

    func configure(isBlind: Bool) {
        descriptionView.isHidden = isBlind
        cardView.isHidden = isBlind
        blindImageView.isHidden = !isBlind
    }
    
    func configureHeaderView(profileImageURL: URL?, userName: String?) {
        userNameLabel.text = userName
                
        guard let profileImageURL,
              !profileImageURL.absoluteString.isEmpty
        else {
             return
        }
        
        profileImageView.kf.setImage(with: profileImageURL, placeholder: UIImage(resource: .imgProfilePurple))
    }
    
    func configureDescriptionView(description: String?) {
        descriptionLabel.text = description
    }
    
    func configureCardView(
        thumbnailImageURL: URL?,
        title: String?,
        siteName: String?,
        isLiked: Bool,
        likeCount: Int
    ) {
        titleLabel.text = title
        siteNameLabel.text = siteName
        likeButton.configureButton(isLiked: isLiked, likeCount: likeCount, postType: .content)
        
        guard let thumbnailImageURL,
              !thumbnailImageURL.absoluteString.isEmpty,
              thumbnailImageURL.absoluteString != Constant.defaultImageURLString
        else {
            return
        }
        
        thumbnailImageView.kf.setImage(with: thumbnailImageURL, placeholder: UIImage(resource: .imgViewitThumnail))
    }
    
    // MARK: - Action Method

    @objc func profileInfoDidTap() {
        profileInfoDidTapClosure?()
    }
    
    @objc func meatBallDidTap() {
        meatballDidTapClosure?()
    }
    
    @objc func cardDidTap() {
        cardDidTapClosure?()
    }
    
    @objc func likeDidTap() {
        let newCount = likeButton.isLiked ? likeButton.likeCount - 1 : likeButton.likeCount + 1
        
        likeButton.configureButton(isLiked: !likeButton.isLiked, likeCount: newCount, postType: .content)
        
        likeDidTapClosure?()
    }
    
    // MARK: - Constant
    
    enum Constant {
        static let profileImageViewSize: CGFloat = 28
        static let etcButtonSize: CGFloat = 32
        static let defaultImageURLString = "DEFAULT"
    }
}
