//
//  RankCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import UIKit

import SnapKit
import Then

final class RankCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    private let rankLabel = UILabel().then {
        $0.attributedText = "0".pretendardString(with: .body3)
    }

    private let teamLogoImageView = UIImageView()
    
    private let teamNameLabel = UILabel().then {
        $0.attributedText = "이름".pretendardString(with: .body3)
    }
    
    private let teamStatsStackView = UIStackView(axis: .horizontal).then {
        $0.spacing = 12
        $0.distribution = .fillEqually
        $0.alignment = .center
    }
    
    private let winCountLabel = UILabel().then {
        $0.attributedText = "0".pretendardString(with: .body4)
    }
    
    private let defeatCountLabel = UILabel().then {
        $0.attributedText = "0".pretendardString(with: .body4)
    }
    
    private let winningRateLabel = UILabel().then {
        $0.attributedText = "0%".pretendardString(with: .body4)
    }
    
    private let scoreGapLabel = UILabel().then {
        $0.attributedText = "0".pretendardString(with: .body4)
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
    
    func configure(
        rank: Int,
        teamLogoImage: UIImage?,
        teamName: String,
        winCount: Int,
        defeatCount: Int,
        winningRate: Int,
        scoreGap: Int
    ) {
        rankLabel.text = "\(rank)"
        teamLogoImageView.image = teamLogoImage
        teamNameLabel.text = teamName
        
        winCountLabel.text = "\(winCount)"
        defeatCountLabel.text = "\(defeatCount)"
        winningRateLabel.text = "\(winningRate)%"
        scoreGapLabel.text = "\(scoreGap)"
    }
}

// MARK: - Setup Method

private extension RankCell {
    func setupView() {
        teamStatsStackView.addArrangedSubviews(
            winCountLabel,
            defeatCountLabel,
            winningRateLabel,
            scoreGapLabel
        )
        
        contentView.addSubviews(
            rankLabel,
            teamLogoImageView,
            teamNameLabel,
            teamStatsStackView
        )
    }
    
    func setupConstraint() {
        rankLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        teamLogoImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(4)
            make.leading.equalTo(rankLabel.snp.trailing).offset(20)
            make.width.equalTo(teamLogoImageView.snp.height)
        }
        
        teamNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(teamLogoImageView.snp.trailing).offset(12)
        }
        
        teamStatsStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }
    }
}
