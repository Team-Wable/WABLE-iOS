//
//  ProfileRegisterView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

import Kingfisher

final class ProfileRegisterView: UIView {
    
    // MARK: Property

    var defaultImageList = [
        DefaultProfileType.blue,
        DefaultProfileType.green,
        DefaultProfileType.purple
    ]
    
    // MARK: - UIComponent
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = " ".pretendardString(with: .head0)
        $0.textColor = .wableBlack
        $0.numberOfLines = 2
    }
    
    private let descriptionLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.ProfileSetting.registerDescription.pretendardString(with: .body2)
        $0.textColor = .gray600
        $0.isHidden = true
    }
    
    let profileImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = (166 / 2).adjustedWidth
        $0.clipsToBounds = true
    }
    
    lazy var switchButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.image = .icChange
    }
    
    lazy var addButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.image = .icProfileplus
    }
    
    let nickNameTextField: UITextField = UITextField(
        pretendard: .body2,
        placeholder: "예) 중꺾마"
    ).then {
        $0.textColor = .wableBlack
        $0.layer.cornerRadius = 6.adjustedWidth
        $0.backgroundColor = .gray200
        $0.addPadding(left: 16)
    }
    
    let duplicationCheckButton: UIButton = UIButton(configuration: .filled()).then {
        $0.configuration?.attributedTitle = "중복확인".pretendardString(with: .body3)
        $0.configuration?.baseForegroundColor = .gray600
        $0.configuration?.baseBackgroundColor = .gray200
        $0.isUserInteractionEnabled = false
    }
    
    let conditiionLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.ProfileSetting.checkDefaultMessage.pretendardString(with: .caption2)
        $0.textColor = .gray600
    }
    
    let nextButton: WableButton = WableButton(style: .gray).then {
        $0.configuration?.attributedTitle = "다음으로".pretendardString(with: .head2)
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public Extension

extension ProfileRegisterView {
    func configureDefaultImage() {
        defaultImageList.shuffle()
        
        profileImageView.image = UIImage(named: defaultImageList[0].rawValue)
    }
}

// MARK: - Private Extension

private extension ProfileRegisterView {
    
    // MARK: Setup Method
    
    func setupView() {
        addSubviews(
            titleLabel,
            descriptionLabel,
            profileImageView,
            switchButton,
            addButton,
            nickNameTextField,
            duplicationCheckButton,
            conditiionLabel,
            nextButton
        )
    }
    
    func setupConstraint() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(16)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(48)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(166.adjustedWidth)
        }
        
        switchButton.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.leading).offset(-2)
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(-12)
            $0.size.equalTo(48.adjustedWidth)
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(2)
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(-12)
            $0.size.equalTo(48.adjustedWidth)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(duplicationCheckButton.snp.leading).offset(-8)
            $0.adjustedHeightEqualTo(48)
        }
        
        duplicationCheckButton.snp.makeConstraints {
            $0.centerY.equalTo(nickNameTextField)
            $0.trailing.equalToSuperview().inset(16)
            $0.adjustedWidthEqualTo(94)
            $0.adjustedHeightEqualTo(48)
        }
        
        conditiionLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(9)
            $0.leading.equalToSuperview().inset(16)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(30)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(56)
        }
    }
}

extension ProfileRegisterView {
    
    // MARK: Configure Method
    
    func configureView(profileImageURL: URL? = .none) {
        titleLabel.text = StringLiterals.ProfileSetting.registerTitle
        descriptionLabel.isHidden = false
        
        guard let profileImageURL = profileImageURL else {
            configureDefaultImage()
            
            return
        }
        
        profileImageView.kf.setImage(with: profileImageURL)
    }
    
    func configureProfileView(profileImageURL: URL? = .none) {
        titleLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(28)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(62)
            make.centerX.equalToSuperview()
            make.size.equalTo(166.adjustedWidth)
        }
        
        titleLabel.text = StringLiterals.ProfileSetting.editTitle
        nextButton.configuration?.attributedTitle = "완료".pretendardString(with: .head2)
        nextButton.isUserInteractionEnabled = true
        nextButton.updateStyle(.primary)
        
        guard let profileImageURL = profileImageURL else {
            configureDefaultImage()
            
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
            profileImageView.kf.setImage(
                with: profileImageURL,
                placeholder: [UIImage.imgProfilePurple, UIImage.imgProfileBlue, UIImage.imgProfileGreen].randomElement()
            )
        }
    }
}
