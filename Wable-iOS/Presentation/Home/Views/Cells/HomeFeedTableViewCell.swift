//
//  HomeFeedTableViewCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

import SnapKit

final class HomeFeedTableViewCell: UITableViewCell{
    
    // MARK: - Properties
    
    static let identifier = "HomeFeedTableViewCell"
    var menuButtonTapped: (() -> Void)?
    var isMyContent: Bool = Bool()
    
    // MARK: - Components
    
    private var infoView = FeedInfoView()
    var feedContentView = FeedContentView()
    var bottomView = FeedBottomView()
    
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
    
    var seperateLineView: UIView = {
       let view = UIView()
        view.backgroundColor = .gray200
        view.isHidden = true
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedContentView = FeedContentView()
    }
    
    // MARK: - Functions

    private func setHierarchy() {
        self.contentView.addSubviews(profileImageView,
                                     menuButton,
                                     infoView,
                                     feedContentView,
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
        
        feedContentView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(31.adjusted)
            $0.top.equalTo(feedContentView.snp.bottom).offset(20.adjusted)
            $0.bottom.equalToSuperview().inset(20.adjusted)
        }
        
        seperateLineView.snp.makeConstraints {
            $0.height.equalTo(8.adjusted)
            $0.leading.trailing.equalToSuperview()
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
    
    func bind(data: HomeFeedDTO) {
        infoView.bind(nickname: data.memberNickname,
                      team: Team(rawValue: data.memberFanTeam) ?? .T1,
                      ghostPercent: data.memberGhost,
                      time: data.time)
        
        feedContentView.bind(title: data.contentTitle,
                             content: data.contentText,
                             image: data.contentImageURL)
        
        bottomView.bind(heart: data.likedNumber,
                        comment: data.commentNumber)
        
    }
}
