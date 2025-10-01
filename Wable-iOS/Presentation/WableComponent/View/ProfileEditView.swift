//
//  ProfileEditView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 6/18/25.
//


import UIKit

import Kingfisher

final class ProfileEditView: UIView {
    
    // MARK: Property

    private(set) var currentDefaultImage: DefaultProfileType = .blue

    private let cellTapped: ((String) -> Void)?
    
    // MARK: - UIComponent
    
    let profileImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = (112 / 2).adjustedWidth
        $0.clipsToBounds = true
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
    
    let conditionLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.ProfileSetting.checkDefaultMessage.pretendardString(with: .caption2)
        $0.textColor = .gray600
    }
    
    let myTeamLabel: UILabel = UILabel().then {
        $0.attributedText = " ".pretendardString(with: .body3)
        $0.textColor = .purple50
    }
    
    lazy var switchButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.image = .icChange
    }
    
    lazy var addButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.image = .icProfileplus
    }
    
    lazy var teamCollectionView: TeamCollectionView = {
        return TeamCollectionView(didTapped: { [weak self] selectedTeam in
            guard let self = self else { return }
            
            myTeamLabel.text = selectedTeam
            cellTapped?(selectedTeam)
        })
    }()
    
    private let nicknameDiscriptionLabel: UILabel = UILabel().then {
        $0.attributedText = "닉네임".pretendardString(with: .body3)
        $0.textColor = .wableBlack
    }
    
    private let teamDescriptionLabel: UILabel = UILabel().then {
        $0.attributedText = "응원팀".pretendardString(with: .body3)
        $0.textColor = .wableBlack
    }
    
    // MARK: - LifeCycle
    
    init(cellTapped: ((String) -> Void)?) {
        self.cellTapped = cellTapped
        
        super.init(frame: .zero)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Extension

extension ProfileEditView {
    func configureDefaultImage() {
        currentDefaultImage = DefaultProfileType.random()
        profileImageView.image = currentDefaultImage.image
    }
}

// MARK: - Private Extension

private extension ProfileEditView {
    
    // MARK: Setup Method
    
    func setupView() {
        addSubviews(
            profileImageView,
            switchButton,
            addButton,
            nicknameDiscriptionLabel,
            nickNameTextField,
            conditionLabel,
            duplicationCheckButton,
            teamDescriptionLabel,
            myTeamLabel,
            teamCollectionView
        )
    }
    
    func setupConstraint() {
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(112.adjustedWidth)
        }
        
        switchButton.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.leading).offset(-17)
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(6)
            $0.size.equalTo(48.adjustedWidth)
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalTo(profileImageView.snp.trailing).offset(19)
            $0.bottom.equalTo(profileImageView.snp.bottom).offset(6)
            $0.size.equalTo(48.adjustedWidth)
        }
        
        nicknameDiscriptionLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(16)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameDiscriptionLabel.snp.bottom).offset(4)
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
        
        conditionLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(9)
            $0.leading.equalToSuperview().inset(16)
        }
        
        teamDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(conditionLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
        }
        
        myTeamLabel.snp.makeConstraints {
            $0.centerY.equalTo(teamDescriptionLabel)
            $0.leading.equalTo(teamDescriptionLabel.snp.trailing).offset(4)
        }
        
        teamCollectionView.snp.makeConstraints {
            $0.top.equalTo(teamDescriptionLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(368)
        }
    }
}

extension ProfileEditView {
    
    // MARK: Configure Method
    
    func configureView(profileImageURL: URL? = .none, team: LCKTeam?) {
        myTeamLabel.text = team?.rawValue ?? "LCK"
        teamCollectionView.selectInitialTeam(team: team)
        profileImageView.setProfileImage(with: profileImageURL)
    }
}
