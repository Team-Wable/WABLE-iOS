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
    
    private let contentStackView = UIStackView(axis: .vertical).then {
        $0.spacing = 8
        $0.alignment = .fill
    }
    
    private let statusImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let timeLabel = UILabel().then {
        $0.attributedText = "24:59".pretendardString(with: .body3)
        $0.textColor = .gray900
    }
    
    private let scoreView = UIView().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.gray200.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let homeTeamLogoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 22
    }
    
    private let homeTeamNameLabel = UILabel().then {
        $0.attributedText = "TBD".pretendardString(with: .body3)
        $0.textColor = .gray700
    }
    
    private let homeTeamScoreLabel = UILabel().then {
        $0.attributedText = "0".pretendardString(with: .head0)
        $0.textColor = .wableBlack
    }
    
    private let colonImageView = UIImageView(image: .icVersus.withRenderingMode(.alwaysOriginal))
    
    private let awayTeamScoreLabel = UILabel().then {
        $0.attributedText = "0".pretendardString(with: .head0)
        $0.textColor = .wableBlack
    }
    
    private let awayTeamNameLabel = UILabel().then {
        $0.attributedText = "TBD".pretendardString(with: .body3)
        $0.textColor = .gray700
    }
    
    private let awayTeamLogoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 22
    }
    
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
        
        configure(
            gameStatusImage: nil,
            gameTime: "12.31 (목)",
            homeTeamLogoImage: nil,
            homeTeamName: "TBD",
            homeTeamScore: 0,
            awayTeamScore: 0,
            awayTeamName: "TBD",
            awayTeamLogoImage: nil
        )
    }
    
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
        statusImageView.image = gameStatusImage
        timeLabel.text = gameTime
        
        homeTeamLogoImageView.image = homeTeamLogoImage
        homeTeamNameLabel.text = homeTeamName
        homeTeamScoreLabel.text = "\(homeTeamScore)"
        
        awayTeamScoreLabel.text = "\(awayTeamScore)"
        awayTeamNameLabel.text = awayTeamName
        awayTeamLogoImageView.image = awayTeamLogoImage
    }
}

// MARK: - Setup Method

private extension GameScheduleCell {
    func setupView() {
        let statusView = UIView()
        statusView.addSubviews(
            statusImageView,
            timeLabel
        )
        
        scoreView.addSubviews(
            homeTeamLogoImageView,
            homeTeamNameLabel,
            homeTeamScoreLabel,
            colonImageView,
            awayTeamScoreLabel,
            awayTeamNameLabel,
            awayTeamLogoImageView
        )
        
        contentStackView.addArrangedSubviews(
            statusView,
            scoreView
        )
        
        contentView.addSubview(contentStackView)
    }
    
    func setupConstraint() {
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        statusImageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.adjustedWidthEqualTo(32)
            make.adjustedHeightEqualTo(20)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusImageView)
            make.leading.equalTo(statusImageView.snp.trailing).offset(8)
        }
        
        homeTeamLogoImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(20)
            make.adjustedWidthEqualTo(44)
            make.height.equalTo(homeTeamLogoImageView.snp.width)
        }
        
        homeTeamNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(homeTeamLogoImageView.snp.trailing).offset(8)
        }
        
        homeTeamScoreLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(colonImageView.snp.leading).offset(-24)
        }
        
        colonImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.adjustedWidthEqualTo(4)
        }
        
        awayTeamScoreLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(colonImageView.snp.trailing).offset(24)
        }
        
        awayTeamNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(awayTeamLogoImageView.snp.leading)
        }
        
        awayTeamLogoImageView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(homeTeamLogoImageView)
            make.trailing.equalToSuperview().offset(-20)
            make.size.equalTo(homeTeamLogoImageView)
        }
    }
}
