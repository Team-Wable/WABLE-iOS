//
//  ATeamView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class ATeamView: UIView {
    private let teamImageView = UIImageView()
    private let teamNameLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.textColor = .gray700
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .head0
        label.textColor = .wableBlack
        return label
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ATeamView {
    func bind(team: String, score: Int) {
        teamImageView.image = Team(rawValue: team)?.logo
        teamNameLabel.text = team
        scoreLabel.text = "\(score)"
    }
}

// MARK: - Private Method

extension ATeamView {
    func setupView() {
        addSubviews(teamImageView, teamNameLabel, scoreLabel)
    }
    
    func setupConstraints() {
        teamImageView.snp.makeConstraints {
            $0.height.width.equalTo(44.adjusted)
            $0.leading.centerY.equalToSuperview()
        }
        
        teamNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(teamImageView.snp.trailing).offset(6.adjusted)
        }
        
        scoreLabel.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
    }
}
