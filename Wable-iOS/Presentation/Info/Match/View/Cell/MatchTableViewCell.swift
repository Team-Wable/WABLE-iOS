//
//  MatchTableViewCell.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class MatchTableViewCell: UITableViewCell {
    private let matchProgressStatusView = MatchProgressStatusView()
    private let teamScoreView = TeamScoreView()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MatchTableViewCell {
    func bind(data: Game) {
        matchProgressStatusView.bind(status: data.gameStatus, time: data.gameDate)
        teamScoreView.bind(data: data)
    }
}

// MARK: - Private Method

private extension MatchTableViewCell {
    func setupView() {
        contentView.addSubviews(matchProgressStatusView, teamScoreView)
    }
    
    func setupConstraints() {
        matchProgressStatusView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(22.adjusted)
            $0.width.equalTo(77.adjusted)
        }
        
        teamScoreView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(16.adjusted)
            $0.top.equalTo(matchProgressStatusView.snp.bottom).offset(6.adjusted)
        }
    }
}
 
