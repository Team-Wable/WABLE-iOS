//
//  RankDescriptionView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/22/24.
//

import UIKit

import SnapKit

final class RankDescriptionView: UIView {
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.text = "순위"
        label.font = .caption4
        label.textColor = .gray600
        label.textAlignment = .center
        return label
    }()
    
    private let teamLabel: UILabel = {
        let label = UILabel()
        label.text = "팀"
        label.font = .caption4
        label.textColor = .gray600
        label.textAlignment = .center
        return label
    }()
    
    private let winLabel: UILabel = {
        let label = UILabel()
        label.text = "승"
        label.font = .caption4
        label.textColor = .gray600
        label.textAlignment = .center
        return label
    }()
    
    private let defeatLabel: UILabel = {
        let label = UILabel()
        label.text = "패"
        label.font = .caption4
        label.textColor = .gray600
        label.textAlignment = .center
        return label
    }()
    
    private let winningRateLabel: UILabel = {
        let label = UILabel()
        label.text = "승률"
        label.font = .caption4
        label.textColor = .gray600
        label.textAlignment = .center
        return label
    }()
    
    private let scoreDiffLabel: UILabel = {
        let label = UILabel()
        label.text = "득점차"
        label.font = .caption4
        label.textColor = .gray600
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
}

// MARK: - Private Method

private extension RankDescriptionView {
    func setupView() {
        backgroundColor = .gray200
        layer.cornerRadius = 8.adjusted
        
        addSubviews(
            rankLabel,
            teamLabel,
            winLabel,
            defeatLabel,
            winningRateLabel,
            scoreDiffLabel
        )
    }
    
    func setupConstraints() {
        rankLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        teamLabel.snp.makeConstraints { make in
            make.leading.equalTo(rankLabel.snp.trailing).offset(24)
            make.centerY.equalTo(rankLabel)
        }
        
        winLabel.snp.makeConstraints { make in
            make.trailing.equalTo(defeatLabel.snp.leading).offset(-24)
            make.centerY.equalTo(rankLabel)
        }
        
        defeatLabel.snp.makeConstraints { make in
            make.trailing.equalTo(winningRateLabel.snp.leading).offset(-24)
            make.centerY.equalTo(rankLabel)
        }
        
        winningRateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(scoreDiffLabel.snp.leading).offset(-24)
            make.centerY.equalTo(rankLabel)
        }
        
        scoreDiffLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(rankLabel)
        }
    }
}
