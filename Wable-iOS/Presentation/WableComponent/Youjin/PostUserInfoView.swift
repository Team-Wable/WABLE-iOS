//
//  PostUserInfoView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

import Kingfisher

final class PostUserInfoView: UIView {
    
    // MARK: Property
    
    let profileImageView: UIImageView = UIImageView().then {
        $0.roundCorners([.all], radius: 36 / 2)
        $0.isUserInteractionEnabled = true
    }
    
    private let fanTeamImageView: UIImageView = UIImageView()
    
    private let userNameLabel: UILabel = UILabel().then {
        $0.textColor = .wableBlack
    }
    
    private let ghostCountLabel: UILabel = UILabel().then {
        $0.textColor = .gray700
    }
    
    private let postTimeLabel: UILabel = UILabel().then {
        $0.textColor = .gray500
    }
    
    lazy var settingButton: UIButton = UIButton().then {
        $0.setImage(.icMeatball, for: .normal)
    }
    
    // MARK: - LifeCycle
    
    init() {
        super.init(frame: .zero)
        
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
            profileImageView,
            fanTeamImageView,
            userNameLabel,
            ghostCountLabel,
            postTimeLabel,
            settingButton
        )
    }
    
    private func setupConstraint() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.adjustedWidthEqualTo(36)
            $0.adjustedHeightEqualTo(36)
        }
        
        userNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        fanTeamImageView.snp.makeConstraints {
            $0.centerY.equalTo(userNameLabel)
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(8)
            $0.adjustedWidthEqualTo(37)
            $0.adjustedHeightEqualTo(19)
        }
        
        ghostCountLabel.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(2)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.bottom.equalToSuperview()
        }
        
        postTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(ghostCountLabel)
            $0.leading.equalTo(ghostCountLabel.snp.trailing).offset(6)
        }
        
        settingButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(16)
            $0.adjustedWidthEqualTo(32)
            $0.adjustedHeightEqualTo(32)
        }
    }
    
    private func setupAction() {
        settingButton.addTarget(self, action: #selector(settingButtonDidTap), for: .touchUpInside)
    }
}

// MARK: - Extension

extension PostUserInfoView {
    func configureView(
        userProfileURL: URL,
        userName: String,
        userFanTeam: LCKTeam,
        opacity: Int,
        createdDate: Date,
        postType: PostType
    ) {
        switch postType {
        case .content:
            userNameLabel.attributedText = userName.pretendardString(with: .body3)
        case .comment:
            userNameLabel.attributedText = userName.pretendardString(with: .caption1)
        }
        
        profileImageView.kf.setImage(with: userProfileURL)
        fanTeamImageView.image = UIImage(named: "tag_\(userFanTeam.rawValue)")
        ghostCountLabel.attributedText = "투명도 \(opacity)%".pretendardString(with: .caption4)
        postTimeLabel.attributedText = configurePostTime(date: createdDate).pretendardString(with: .caption4)
        fanTeamImageView.isHidden = true
    }
}

private extension PostUserInfoView {
    @objc func settingButtonDidTap() {
        // TODO: 바텀시트 올리는 로직 구현 필요
    }
    
    func configurePostTime(date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        let seconds = Int(timeInterval)
        
        switch seconds {
        case ..<60:
            return "· 지금"
        case 60...(60 * 60):
            let minutes = seconds / 60
            return "· \(minutes)분 전"
        case (60 * 60 + 1)...(24 * 60 * 60):
            let hours = seconds / (60 * 60)
            return "· \(hours)시간 전"
        case (24 * 60 * 60 + 1)...(7 * 24 * 60 * 60):
            let days = seconds / (24 * 60 * 60)
            return "· \(days)일 전"
        case (7 * 24 * 60 * 60 + 1)...(4 * 7 * 24 * 60 * 60):
            let weeks = seconds / (7 * 24 * 60 * 60)
            return "· \(weeks)주 전"
        case (4 * 7 * 24 * 60 * 60 + 1)...(12 * 30 * 24 * 60 * 60):
            let months = seconds / (30 * 24 * 60 * 60)
            return "· \(months)달 전"
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            return dateFormatter.string(from: date)
        }
    }
}
