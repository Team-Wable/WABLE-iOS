//
//  MyPageProfileView.swift
//  Wable-iOS
//
//  Created by 변상우 on 8/19/24.
//

import UIKit

import SnapKit

final class MyPageProfileView: UIView {

    // MARK: - Properties
    
    var transparencyValue: Int = 0 {
        didSet {
            self.transparencyLabel.text = "\(self.transparencyValue)%"
        }
    }
    
    // MARK: - UI Components
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgProfile1
        imageView.layer.cornerRadius = 41.adjusted
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let levelTagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Tag.tagLevel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let userNickname: UILabel = {
        let label = UILabel()
        label.text = "{%nickname}"
        label.textColor = .wableBlack
        label.font = .head2
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Icon.icEdit, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let userIntroductionView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray100
        view.layer.cornerRadius = 8.adjusted
        return view
    }()
    
    let userIntroductionLabel: UILabel = {
        let label = UILabel()
        label.setTextWithLineHeight(text: "", lineHeight: 20.adjusted, alignment: .left)
        label.text = StringLiterals.MyPage.profileIntroduction
        label.textColor = .gray700
        label.font = .body4
        label.numberOfLines = 2
        return label
    }()
    
    let transparencyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.MyPage.transparencyTitle
        label.textColor = .wableBlack
        label.font = .caption1
        return label
    }()
    
    let ghostImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Icon.icGhostPurple
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let transparencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .wableBlack
        label.font = .body3
        return label
    }()
    
    private let emptyTransparencyPercentage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgEmptyBar
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let fullTransparencyPercentage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgFullBar
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let halfTransparencyPercentage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgHalfBar
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let badgeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.MyPage.badgeTitle
        label.textColor = .wableBlack
        label.font = .caption1
        return label
    }()
    
    let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Image.imgBadge
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension MyPageProfileView {
    private func setUI() {
        self.backgroundColor = .wableWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(profileImageView,
                         levelTagImageView,
                         userNickname,
                         editButton,
                         userIntroductionView,
                         transparencyTitleLabel,
                         ghostImageView,
                         transparencyLabel,
                         emptyTransparencyPercentage,
                         fullTransparencyPercentage,
                         halfTransparencyPercentage,
                         badgeTitleLabel,
                         badgeImageView)
        
        userIntroductionView.addSubview(userIntroductionLabel)
    }
    
    private func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(16.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.size.equalTo(82.adjusted)
        }
        
        levelTagImageView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top).offset(12.5.adjusted)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16.adjusted)
            $0.height.equalTo(24.adjusted)
        }
        
        userNickname.snp.makeConstraints {
            $0.top.equalTo(levelTagImageView.snp.bottom).offset(6.adjusted)
            $0.leading.equalTo(levelTagImageView.snp.leading)
        }
        
        editButton.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView.snp.centerY)
            $0.trailing.equalToSuperview().inset(15.adjusted)
            $0.size.equalTo(48.adjusted)
        }
        
        userIntroductionView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(17.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(68.adjusted)
        }
        
        userIntroductionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12.adjusted)
        }
        
        transparencyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(userIntroductionView.snp.bottom).offset(12.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        
        ghostImageView.snp.makeConstraints {
            $0.centerY.equalTo(transparencyTitleLabel.snp.centerY)
            $0.trailing.equalTo(transparencyLabel.snp.leading).offset(-8.adjusted)
        }
        
        transparencyLabel.snp.makeConstraints {
            $0.centerY.equalTo(transparencyTitleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(16.adjusted)
        }
        
        emptyTransparencyPercentage.snp.makeConstraints {
            $0.top.equalTo(transparencyTitleLabel.snp.bottom).offset(6.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(10.adjusted)
        }
        
        fullTransparencyPercentage.snp.makeConstraints {
            $0.top.equalTo(emptyTransparencyPercentage)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(10.adjusted)
        }
        
        halfTransparencyPercentage.snp.makeConstraints {
            $0.top.equalTo(emptyTransparencyPercentage)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(10.adjusted)
        }
        
        badgeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(emptyTransparencyPercentage.snp.bottom).offset(16.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        badgeImageView.snp.makeConstraints {
            $0.top.equalTo(badgeTitleLabel.snp.bottom).offset(6.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
    }
}
