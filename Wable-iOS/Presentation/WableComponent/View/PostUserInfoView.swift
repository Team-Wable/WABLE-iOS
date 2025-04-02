//
//  PostUserInfoView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/11/25.
//


import UIKit

import Kingfisher

/// 게시물이나 댓글의 작성자 정보를 표시하는 뷰.
/// 프로필 이미지, 사용자명, 좋아하는 팀, 투명도, 작성 시간, 설정 버튼을 포함합니다.
///
/// 사용 예시:
/// ```swift
/// let infoView = PostUserInfoView()
/// infoView.configureView(
///     userProfileURL: profileURL,
///     userName: "사용자이름",
///     userFanTeam: .t1,
///     opacity: 80,
///     createdDate: Date(),
///     postType: .content
/// )
/// containerView.addSubview(infoView)
/// ```
final class PostUserInfoView: UIView {
    
    // MARK: UIComponent
    
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
}

// MARK: - Private Extension

private extension PostUserInfoView {
    
    // MARK: - Setup

    func setupView() {
        addSubviews(
            profileImageView,
            fanTeamImageView,
            userNameLabel,
            ghostCountLabel,
            postTimeLabel,
            settingButton
        )
    }
    
    func setupConstraint() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(3)
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
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
            $0.bottom.equalToSuperview().inset(1)
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
    
    func setupAction() {
        settingButton.addTarget(self, action: #selector(settingButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - @objc Method
    
    @objc func settingButtonDidTap() {
        // TODO: 바텀시트 올리는 로직 구현 필요
    }
    
    /// 게시물 작성 시간을 상대적인 시간 문자열로 변환
    /// - Parameter date: 게시물 작성 날짜
    /// - Returns: "지금", "n분 전", "n시간 전" 등의 형식으로 변환된 문자열
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


// MARK: - Configure Extension

extension PostUserInfoView {
    /// 사용자 정보 뷰 구성 메서드
    /// - Parameters:
    ///   - userProfileURL: 사용자 프로필 이미지 URL
    ///   - userName: 사용자 이름
    ///   - userFanTeam: 사용자 팬팀
    ///   - opacity: 사용자 투명도 값 (0~100)
    ///   - createdDate: 게시물 작성 날짜
    ///   - postType: 게시물 타입 (.content 또는 .comment)
    func configureView(
        userProfileURL: URL?,
        userName: String,
        userFanTeam: LCKTeam?,
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
        
        profileImageView.kf.setImage(
            with: userProfileURL,
            placeholder: [UIImage.imgProfilePurple, UIImage.imgProfileBlue, UIImage.imgProfileGreen].randomElement()
        )
        
        // fanTeamImageView.image = UIImage(named: "tag_\(userFanTeam.rawValue)")
        ghostCountLabel.attributedText = "투명도 \(opacity)%".pretendardString(with: .caption4)
        postTimeLabel.attributedText = configurePostTime(date: createdDate).pretendardString(with: .caption4)
        fanTeamImageView.isHidden = true
    }
}
