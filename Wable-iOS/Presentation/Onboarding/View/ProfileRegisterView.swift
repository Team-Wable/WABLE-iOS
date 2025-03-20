//
//  ProfileRegisterView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

import Kingfisher

final class ProfileRegisterView: UIView {
    
    // MARK: - UIComponent
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = "와블에서 활동할\n프로필을 등록해 주세요".pretendardString(with: .head0)
        $0.textColor = .wableBlack
        $0.numberOfLines = 2
    }
    
    private let descriptionLabel: UILabel = UILabel().then {
        $0.attributedText = "프로필 사진은 나중에도 등록 가능해요".pretendardString(with: .body2)
        $0.textColor = .gray600
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
    
    let nickNameTextField: UITextField = UITextField().then {
        $0.setPretendard(with: .body2)
        $0.placeholder = "예) 중꺾마"
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
        $0.attributedText = "10자리 이내, 문자/숫자로 입력 가능해요".pretendardString(with: .caption2)
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
        let defaultImage = [
            DefaultProfileType.blue,
            DefaultProfileType.green,
            DefaultProfileType.purple
        ].shuffled()[0]
        
        profileImageView.image = UIImage(named: defaultImage.rawValue)
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
        
        configureView()
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
    
    // MARK: Configure Method
    
    func configureView(profileImageURL: URL? = .none) {
        guard let profileImageURL = profileImageURL else {
            configureDefaultImage()
            
            return
        }
        
        profileImageView.kf.setImage(with: profileImageURL)
    }
}
