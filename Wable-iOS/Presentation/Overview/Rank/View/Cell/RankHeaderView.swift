//
//  RankHeaderView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/22/25.
//

import UIKit

import SnapKit
import Then

final class RankHeaderView: UICollectionReusableView {
    
    // MARK: - UIComponent
    
    private let rankLabel: UILabel = .init().then {
        $0.attributedText = "순위".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
    }
    
    private let teamLabel: UILabel = .init().then {
        $0.attributedText = "팀".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
    }
    
    private let winLabel: UILabel = .init().then {
        $0.attributedText = "승".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
        $0.textAlignment = .right
    }
        
    private let defeatLabel: UILabel = .init().then {
        $0.attributedText = "패".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
        $0.textAlignment = .right
    }
    
    private let winnningRateLabel: UILabel = .init().then {
        $0.attributedText = "승률".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
        $0.textAlignment = .right
    }
    
    private let scoreGapLabel: UILabel = .init().then {
        $0.attributedText = "득점차".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
        $0.textAlignment = .right
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
}

// MARK: - Setup Method

private extension RankHeaderView {
    func setupView() {
        backgroundColor = UIColor("EDEDED")
        layer.cornerRadius = 8
                
        addSubviews(
            rankLabel,
            teamLabel,
            winLabel,
            defeatLabel,
            winnningRateLabel,
            scoreGapLabel
        )
    }
    
    func setupConstraint() {
        rankLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(12)
        }
        
        teamLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(56)
        }
        
        winLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-148)
        }
        
        defeatLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-112)
        }
        
        winnningRateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-68)
        }
        
        scoreGapLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
        }
    }
}

// MARK: - Constant

private extension RankHeaderView {
    enum Constant {
        static let pretendardStyle: UIFont.Pretendard = .caption4
        static let textColor: UIColor = .gray600
    }
}
