//
//  GameScheduleCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import UIKit

import SnapKit
import Then

final class GameScheduleCell: UICollectionViewCell {
    
    // MARK: - UIComponent

    private let gameStatusImageView = UIImageView()
    
    private let gameTimeLabel = UILabel().then {
        $0.textColor = .gray900
    }
    
    private let borderView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.gray200.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let homeTeamLogoImageView = UIImageView()
    
    private let homeTeamNameLabel = UILabel().then {
        $0.textColor = .gray700
    }
    
    private let homeTeamScoreLabel = UILabel().then {
        $0.textColor = .wableBlack
    }
    
    private let colonImageView = UIImageView(image: .icVersus)
    
    private let awayTeamScoreLabel = UILabel().then {
        $0.textColor = .wableBlack
    }
    
    private let awayTeamNameLabel = UILabel().then {
        $0.textColor = .gray700
    }
    
    private let awayTeamLogoImageView = UIImageView()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        gameStatusImageView.image = nil
        homeTeamLogoImageView.image = nil
        awayTeamLogoImageView.image = nil
    }
}

// MARK: - Public Method

extension GameScheduleCell {
    func configure(
        gameStatusImage: UIImage?,
        gameTime: String,
        homeTeamLogoImage: UIImage?,
        homeTeamName: String,
        homeTeamScore: Int,
        awayTeamScore: Int,
        awayTeamName: String,
        awayTeamLogoImage: UIImage?
    ) {
        gameStatusImageView.image = gameStatusImage
        gameTimeLabel.attributedText = gameTime.pretendardString(with: .body3)
        
        homeTeamLogoImageView.image = homeTeamLogoImage
        homeTeamNameLabel.attributedText = homeTeamName.pretendardString(with: .body3)
        homeTeamScoreLabel.attributedText = "\(homeTeamScore)".pretendardString(with: .head0)
        
        awayTeamScoreLabel.attributedText = "\(awayTeamScore)".pretendardString(with: .head0)
        awayTeamNameLabel.attributedText = awayTeamName.pretendardString(with: .body3)
        awayTeamLogoImageView.image = awayTeamLogoImage
    }
}

// MARK: - Setup Method

private extension GameScheduleCell {
    func setupView() {
        borderView.addSubviews(
            homeTeamLogoImageView,
            homeTeamNameLabel,
            homeTeamScoreLabel,
            colonImageView,
            awayTeamScoreLabel,
            awayTeamNameLabel,
            awayTeamLogoImageView
        )
        
        contentView.addSubviews(
            gameStatusImageView,
            gameTimeLabel,
            borderView
        )
    }
    
    func setupConstraint() {
        gameStatusImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.adjustedWidthEqualTo(32)
            make.adjustedHeightEqualTo(20)
        }
        
        gameTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(gameStatusImageView)
            make.leading.equalTo(gameStatusImageView).offset(8)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(gameStatusImageView.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        homeTeamLogoImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(homeTeamLogoImageView.snp.height)
        }
        
        homeTeamNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(homeTeamLogoImageView)
            make.leading.equalTo(homeTeamLogoImageView).offset(8)
        }
        
        homeTeamScoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(colonImageView)
            make.trailing.equalTo(colonImageView.snp.leading).offset(-24)
        }
        
        colonImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(28)
            make.centerX.equalToSuperview()
            make.adjustedWidthEqualTo(4)
        }
        
        awayTeamScoreLabel.snp.makeConstraints { make in
            make.centerY.equalTo(colonImageView)
            make.leading.equalTo(colonImageView.snp.trailing).offset(24)
        }
        
        awayTeamNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(awayTeamLogoImageView)
            make.trailing.equalTo(awayTeamLogoImageView.snp.leading).offset(-8)
        }
        
        awayTeamLogoImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(awayTeamLogoImageView.snp.height)
        }
    }
}
