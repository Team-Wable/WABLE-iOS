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
    
    private let statsStackView: UIStackView = .init(axis: .horizontal).then {
        $0.spacing = 24
        $0.distribution = .fillEqually
        $0.alignment = .center
    }
    
    private let winLabel: UILabel = .init().then {
        $0.attributedText = "승".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
    }
        
    private let defeatLabel: UILabel = .init().then {
        $0.attributedText = "패".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
    }
    
    private let winnningRateLabel: UILabel = .init().then {
        $0.attributedText = "승률".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
    }
    
    private let scoreGapLabel: UILabel = .init().then {
        $0.attributedText = "득점차".pretendardString(with: Constant.pretendardStyle)
        $0.textColor = Constant.textColor
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
        backgroundColor = .gray600
        layer.cornerRadius = 8
        
        statsStackView.addArrangedSubviews(
            winLabel,
            defeatLabel,
            winnningRateLabel,
            scoreGapLabel
        )
        
        addSubviews(
            rankLabel,
            teamLabel,
            statsStackView
        )
    }
    
    func setupConstraint() {
        winLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(12)
        }
        
        teamLabel.snp.makeConstraints { make in
            make.centerY.equalTo(winLabel)
            make.leading.equalTo(winLabel.snp.trailing).offset(24)
        }
        
        statsStackView.snp.makeConstraints { make in
            make.centerY.equalTo(winLabel)
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
