//
//  MigratedHomeFeedCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 12/24/24.
//

import Combine
import UIKit

import SnapKit
import CombineCocoa

final class MigratedHomeFeedCell: UICollectionViewCell{
    
    // MARK: - Properties
    
    var cancelBag = CancelBag()
    
    var onMenuButtonTap: (() -> Void)?
    var onProfileImageTap: (() -> Void)?
    var onFeedImageTap: (() -> Void)?
    var onHeartButtonTap: (() -> Void)?
    var onCommentButtonTap: (() -> Void)?
    var onGhostButtonTap: (() -> Void)?
    
    // MARK: - Components
    
    let infoView = FeedInfoView()
    let feedContentView = FeedContentView()
    let bottomView = FeedBottomView()
    let divideLine = UIView().makeDivisionLine()
    let grayView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableWhite
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgProfileSmall
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let seperateLineView: UIView = {
       let view = UIView()
        view.backgroundColor = .gray200
        view.isHidden = true
        return view
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Icon.icMeatball, for: .normal)
        return button
    }()
    
    // MARK: - inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupView()
        setLayout()
        setEventPublisher()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        DispatchQueue.main.async {
            self.profileImageView.contentMode = .scaleAspectFill
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
            self.profileImageView.clipsToBounds = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = UIImage()
        self.feedContentView.blindImageView.isHidden = true
        self.feedContentView.titleLabel.isHidden = false
        self.feedContentView.contentLabel.isHidden = false
        self.feedContentView.photoImageView.isHidden = false
        self.feedContentView.titleLabel.attributedText = nil
        self.feedContentView.titleLabel.textColor = .wableBlack
        self.feedContentView.contentLabel.attributedText = nil
        self.feedContentView.contentLabel.textColor = .gray800
        self.grayView.alpha = 0
    }
    
    // MARK: - Functions

    private func setupView() {
        self.backgroundColor = .wableWhite
        self.contentView.addSubviews(
            profileImageView,
            menuButton,
            infoView,
            feedContentView,
            bottomView,
            divideLine,
            seperateLineView,
            grayView
        )
        
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        self.profileImageView.clipsToBounds = true
    }
    
    private func setLayout() {
        grayView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.snp.top)
        }
        
        profileImageView.snp.makeConstraints {
            $0.height.width.equalTo(36.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.centerY.equalTo(infoView)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(18.adjusted)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10.adjusted)
            $0.height.equalTo(43.adjusted)
        }
        
        menuButton.snp.makeConstraints {
            $0.height.width.equalTo(32.adjusted)
            $0.top.equalTo(infoView)
            $0.trailing.equalToSuperview().inset(16.adjusted)
        }
        
        feedContentView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(31.adjusted)
            $0.top.equalTo(feedContentView.snp.bottom).offset(20.adjusted).priority(.low)
            $0.bottom.equalToSuperview().inset(20.adjusted)
        }
        
        divideLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        seperateLineView.snp.makeConstraints {
            $0.height.equalTo(8.adjusted)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(data: HomeFeedDTO) {
        data.memberProfileURL.isEmpty ?
        (profileImageView.image = ImageLiterals.Image.imgProfile3) :
        profileImageView.load(url: data.memberProfileURL)
        
        infoView.bind(
            nickname: data.memberNickname,
            team: Team(rawValue: data.memberFanTeam) ?? .TBD,
            ghostPercent: data.memberGhost,
            time: data.time
        )
        
        feedContentView.bind(
            title: data.contentTitle ?? "",
            content: data.contentText ?? "",
            image: data.contentImageURL,
            isBlind: data.isBlind
        )
        
        bottomView.bind(
            heart: data.likedNumber,
            comment: data.commentNumber ?? Int(),
            memberID: data.memberID
        )
        
        bottomView.isLiked = data.isLiked
        
        if data.isGhost || data.isBlind ?? false {
            bottomView.ghostButton.setImage(ImageLiterals.Button.btnGhostDisabledLarge, for: .normal)
            bottomView.ghostButton.isEnabled = false
        } else {
            bottomView.ghostButton.setImage(ImageLiterals.Button.btnGhostDefaultLarge, for: .normal)
            bottomView.ghostButton.isEnabled = true
        }
        
        let memberGhost = adjustGhostValue(data.memberGhost)
        
        grayView.alpha = data.isGhost ? 0.85 : CGFloat(Double(-memberGhost) / 100)

    }
    
    func changeButtonState(isLiked: Bool) {
        bottomView.isLiked = isLiked
    }
    
    private func setEventPublisher() {
        let profileImageTapGesture = UITapGestureRecognizer()
        let feedImageTapGesture = UITapGestureRecognizer()
        
        menuButton.tapPublisher
            .sink { [weak self] in
                self?.onMenuButtonTap?()
            }
            .store(in: cancelBag)
        
        profileImageView.gesturePublisher(profileImageTapGesture)
            .sink { [weak self] _ in
                self?.onProfileImageTap?()
            }
            .store(in: cancelBag)

        feedContentView.photoImageView.gesturePublisher(feedImageTapGesture)
            .sink { [weak self] _ in
                self?.onFeedImageTap?()
            }
            .store(in: cancelBag)
        
        bottomView.heartButton.tapPublisher
            .sink { [weak self] in
                self?.onHeartButtonTap?()
            }
            .store(in: cancelBag)
        
        bottomView.commentButton.tapPublisher
            .sink { [weak self] in
                self?.onCommentButtonTap?()
            }
            .store(in: cancelBag)
        
        bottomView.ghostButton.tapPublisher
            .sink { [weak self] in
                self?.onGhostButtonTap?()
            }
            .store(in: cancelBag)
    }
}
