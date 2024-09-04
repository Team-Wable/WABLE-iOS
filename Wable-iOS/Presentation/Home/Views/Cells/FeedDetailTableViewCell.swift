//
//  FeedDetailTableViewCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/19/24.
//

import UIKit

import SnapKit

final class FeedDetailTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "FeedDetailTableViewCell"
    var menuButtonTapped: (() -> Void)?
    var profileButtonAction: (() -> Void) = {}
    var isMyContent: Bool = Bool()
    
    var alarmTriggerType: String = ""
    var targetMemberId: Int = 0
    var alarmTriggerdId: Int = 0
    
    // MARK: - Components
    
    let grayView: UIView = {
        let view = UIView()
        view.backgroundColor = .wableWhite
        view.alpha = 0
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var infoView = FeedInfoView()

    var bottomView = FeedDetailBottomView()
    
    var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray800
        label.font = .body4
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
            label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgProfileSmall
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Icon.icMeatball, for: .normal)
        return button
    }()
    
    private var seperateLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    // MARK: - inits
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .wableWhite
        setHierarchy()
        setLayout()
        setAddTarget()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions

    private func setHierarchy() {
        self.contentView.addSubviews(grayView,
                                     profileImageView,
                                     menuButton,
                                     infoView,
                                     contentLabel,
                                     bottomView,
                                     seperateLineView)
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
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(12.adjusted)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(6.adjusted)
            $0.trailing.equalTo(menuButton)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(31.adjusted)
            $0.top.equalTo(contentLabel.snp.bottom).offset(12.adjusted)
            $0.bottom.equalToSuperview().inset(18.adjusted)
        }
        
        seperateLineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1.adjusted)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setAddTarget() {
        self.menuButton.addTarget(self, action: #selector(menuButtonDidTapped), for: .touchUpInside)
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileButtonTapped)))
    }
    
    @objc
    private func menuButtonDidTapped() {
        menuButtonTapped?()
    }
    
    @objc
    private func profileButtonTapped() {
        profileButtonAction()
    }
    
    func bind(data: FeedDetailReplyDTO) {
        profileImageView.load(url: data.memberProfileUrl)
        
        infoView.bind(nickname: data.memberNickname,
                      team: Team(rawValue: data.memberFanTeam) ?? .T1,
                      ghostPercent: data.memberGhost,
                      time: data.time)
        
        contentLabel.text = data.commentText

        bottomView.bind(heart: data.commentLikedNumber)
        
        bottomView.isLiked = data.isLiked
        
        if data.isGhost {
            bottomView.ghostButton.setImage(ImageLiterals.Button.btnGhostDisabledSmall, for: .normal)
            bottomView.ghostButton.isEnabled = false
        } else {
            bottomView.ghostButton.setImage(ImageLiterals.Button.btnGhostDefaultSmall, for: .normal)
            bottomView.ghostButton.isEnabled = true
        }
        
    }
}
