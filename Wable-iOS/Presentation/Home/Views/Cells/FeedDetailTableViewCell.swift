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
    var isMyContent: Bool = Bool()
    
    // MARK: - Components
    
    private var infoView = FeedInfoView()

    var bottomView = FeedDetailBottomView()
    
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray800
        label.font = .body4
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
            label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgProfileSmall
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
        self.contentView.addSubviews(profileImageView,
                                     menuButton,
                                     infoView,
                                     contentLabel,
                                     bottomView,
                                     seperateLineView)
    }
    
    private func setLayout() {
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
    }
    
    @objc
    private func menuButtonDidTapped() {
        menuButtonTapped?()
    }
    
    func bind(data: FeedDetailReplyDTO) {
        infoView.bind(nickname: data.memberNickname,
                      team: Team(rawValue: data.memberFanTeam) ?? .T1,
                      ghostPercent: data.memberGhost,
                      time: data.time)
        
        contentLabel.text = data.commentText

        bottomView.bind(heart: data.commentLikedNumber)
        
    }
}
