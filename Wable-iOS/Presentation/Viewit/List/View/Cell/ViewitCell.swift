//
//  ViewitCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/12/25.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ViewitCell: UICollectionViewCell {
    
    // MARK: - UIComponent

    private let profileImageView = UIImageView(image: .imgProfileSmall).then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = Constant.profileImageViewSize / 2
        $0.clipsToBounds = true
    }
    
    private let usernameLabel = UILabel().then {
        $0.attributedText = "이름".pretendardString(with: .body3)
    }
    
    private let etcButton = UIButton().then {
        $0.setImage(.icMeatball, for: .normal)
    }
    
    private let viewitContentView = ViewitContentView()
    
    private let blindImageView = UIImageView(image: .imgFeedIsBlind).then {
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configure(profileImageURL: nil, username: "이름")
        configure(
            viewitText: "텍스트",
            videoThumbnailImageURL: nil,
            videoTitle: "동영상 제목",
            siteName: "사이트 이름",
            isLiked: false,
            likeCount: 0
        )
        
        blindImageView.isHidden = true
    }
    
    func configure(profileImageURL: URL?, username: String) {
        profileImageView.kf.setImage(with: profileImageURL, placeholder: UIImage(resource: .imgProfileSmall))
        usernameLabel.text = username
    }
    
    func configure(
        viewitText: String,
        videoThumbnailImageURL: URL?,
        videoTitle: String,
        siteName: String,
        isLiked: Bool,
        likeCount: Int,
        isBlind: Bool = false
    ) {
        guard !isBlind else {
            viewitContentView.isHidden = isBlind
            blindImageView.isHidden = !isBlind
            return
        }
        
        viewitContentView.configure(
            viewitText: viewitText,
            videoThumbnailImageURL: videoThumbnailImageURL,
            videoTitle: videoTitle,
            siteName: siteName,
            isLiked: isLiked,
            likeCount: likeCount
        )
    }
}

// MARK: - Setup Method

private extension ViewitCell {
    func setupCell() {
        let underlineView = UIView(backgroundColor: .gray200)
        
        let contentStackView = UIStackView(axis: .vertical).then {
            $0.alignment = .fill
            $0.distribution = .fill
        }
        contentStackView.addArrangedSubviews(
            viewitContentView,
            blindImageView
        )
        
        contentView.addSubviews(
            profileImageView,
            usernameLabel,
            etcButton,
            contentStackView,
            underlineView
        )
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.adjustedWidthEqualTo(Constant.profileImageViewSize)
            make.adjustedHeightEqualTo(Constant.profileImageViewSize)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }
        
        etcButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.trailing.equalToSuperview().offset(-16)
            make.adjustedWidthEqualTo(Constant.etcButtonSize)
            make.adjustedHeightEqualTo(Constant.etcButtonSize)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(etcButton.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        blindImageView.snp.makeConstraints { make in
            make.adjustedHeightEqualTo(100)
        }
        
        underlineView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}

// MARK: - Constant

private extension ViewitCell {
    enum Constant {
        static let profileImageViewSize: CGFloat = 28
        static let etcButtonSize: CGFloat = 32
    }
}
