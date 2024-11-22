//
//  RankCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/22/24.
//

import UIKit

import SnapKit

final class RankCell: UICollectionViewCell {
    let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.textAlignment = .center
        return label
    }()
    
    let teamLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.textAlignment = .center
        return label
    }()
    
    let winCountLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.textAlignment = .center
        return label
    }()
    
    let defeatCountLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.textAlignment = .center
        return label
    }()
    
    let winningRateLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.textAlignment = .center
        return label
    }()
    
    let scoreDiffLabel: UILabel = {
        let label = UILabel()
        label.font = .body4
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        teamLogoImageView.image = nil
    }
}

// MARK: - Private Method

private extension RankCell {
    func setupView() {
        contentView.addSubviews(
            rankLabel,
            teamLogoImageView,
            teamNameLabel,
            winCountLabel,
            defeatCountLabel,
            winningRateLabel,
            scoreDiffLabel
        )
    }
    
    func setupConstraints() {
        rankLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.size.equalTo(22.adjusted)
        }
        
        teamLogoImageView.snp.makeConstraints { make in
            make.leading.equalTo(rankLabel.snp.trailing).offset(20)
            make.centerY.equalTo(rankLabel)
            make.size.equalTo(30.adjusted)
        }
        
        teamNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(teamLogoImageView.snp.trailing).offset(12)
            make.centerY.equalTo(rankLabel)
        }
        
        winCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(defeatCountLabel.snp.leading).offset(-12)
            make.centerY.equalTo(rankLabel)
            make.size.equalTo(22.adjusted)
        }
        
        defeatCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(winningRateLabel.snp.leading).offset(-12)
            make.centerY.equalTo(rankLabel)
            make.size.equalTo(22.adjusted)
        }
        
        winningRateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(scoreDiffLabel.snp.leading).offset(-12)
            make.centerY.equalTo(rankLabel)
            make.width.equalTo(44.adjusted)
            make.height.equalTo(22.adjustedH)
        }
        
        scoreDiffLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(rankLabel)
            make.width.equalTo(24.adjusted)
            make.height.equalTo(22.adjustedH)
        }
    }
}
