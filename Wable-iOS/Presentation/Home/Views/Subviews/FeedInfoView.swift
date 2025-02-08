//
//  FeedInfoView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/17/24.
//

import UIKit

import SnapKit

final class FeedInfoView: UIView {
    
    // MARK: - UI Components
    
    var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .body3
        label.textColor = .wableBlack
        return label
    }()
    
    var ghostPercentLabel: UILabel = {
        let label = UILabel()
        label.font = .caption4
        label.textColor = .gray700
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .caption4
        label.textColor = .gray500
        return label
    }()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension FeedInfoView {
    
    private func setHierarchy() {
        self.addSubviews(nicknameLabel,
                         ghostPercentLabel,
                         timeLabel)
    }
    
    private func setLayout() {
        nicknameLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(22.adjusted)
        }
        
        ghostPercentLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(2.adjusted)
            $0.leading.equalTo(nicknameLabel)
            $0.height.equalTo(19.adjusted)
        }
        
        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(ghostPercentLabel)
            $0.leading.equalTo(ghostPercentLabel.snp.trailing).offset(6.adjusted)
            $0.height.equalTo(19.adjusted)
        }
    }
    
    func bind(nickname: String, team: Team, ghostPercent: Int, time: String) {
        nicknameLabel.text = nickname
        ghostPercentLabel.text = "투명도 \(ghostPercent)%"
        timeLabel.text = "· \(time.formattedTime())"
    }
}
