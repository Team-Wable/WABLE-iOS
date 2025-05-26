//
//  LCKTeamView.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

final class LCKTeamView: UIView {
    
    // MARK: - UIComponent
    
    private let titleLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Onboarding.teamSheetTitle.pretendardString(with: .head0)
        $0.textColor = .wableBlack
    }
    
    private let descriptionLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Onboarding.teamSheetMessage.pretendardString(with: .body2)
        $0.textColor = .gray600
        $0.numberOfLines = 2
    }

    lazy var teamCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.itemSize = .init(width: 166.adjustedWidth, height: 64.adjustedHeight)
            $0.minimumInteritemSpacing = 11
            $0.minimumLineSpacing = 12
        }).then {
            $0.register(
                LCKTeamCollectionViewCell.self,
                forCellWithReuseIdentifier: LCKTeamCollectionViewCell.reuseIdentifier
            )
            $0.isScrollEnabled = false
        }
    
    lazy var skipButton: UIButton = UIButton(configuration: .plain()).then {
        $0.configuration?.attributedTitle = StringLiterals.Onboarding.teamEmptyButtonTitle.pretendardString(with: .body2)
        $0.configuration?.baseForegroundColor = .gray600
    }
    
    lazy var nextButton: WableButton = WableButton(style: .gray).then {
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

// MARK: - Private Extension

private extension LCKTeamView {
    
    // MARK: Setup Method
    
    func setupView() {
        addSubviews(
            titleLabel,
            descriptionLabel,
            teamCollectionView,
            skipButton,
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
        
        teamCollectionView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.adjustedHeightEqualTo(368)
        }
        
        nextButton.snp.makeConstraints {
            $0.top.equalTo(skipButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(64)
            $0.adjustedHeightEqualTo(56)
        }
        
        skipButton.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
            $0.horizontalEdges.equalToSuperview().inset(48)
            $0.adjustedHeightEqualTo(48)
        }
    }
}
