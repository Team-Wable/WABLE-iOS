//
//  TeamScoreView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/20/24.
//

import UIKit

import SnapKit

final class TeamScoreView: UIView {
    private let aTeamView = ATeamView()
    private let bTeamView = BTeamView()
    private let seperateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.Icon.icVersus
        return imageView
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

extension TeamScoreView {
    func bind(data: Game) {
        aTeamView.bind(team: data.aTeamName, score: data.aTeamScore)
        bTeamView.bind(team: data.bTeamName, score: data.bTeamScore)
    }
}

// MARK: - Private Method

private extension TeamScoreView {
    func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 8.adjusted
        layer.borderWidth = 1.adjusted
        layer.borderColor = UIColor.gray200.cgColor
        
        addSubviews(aTeamView, bTeamView, seperateImageView)
    }
    
    func setupConstraints() {
        self.snp.makeConstraints {
            $0.height.equalTo(72.adjusted)
        }
        
        aTeamView.snp.makeConstraints {
            $0.height.equalTo(44.adjusted)
            $0.leading.equalToSuperview().inset(20.adjusted)
            $0.trailing.equalTo(seperateImageView.snp.leading).offset(-24.adjusted)
            $0.centerY.equalToSuperview()
        }
        
        bTeamView.snp.makeConstraints {
            $0.height.equalTo(44.adjusted)
            $0.trailing.equalToSuperview().inset(20.adjusted)
            $0.leading.equalTo(seperateImageView.snp.trailing).offset(24.adjusted)
            $0.centerY.equalToSuperview()
        }
        
        seperateImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(16.adjusted)
            $0.width.equalTo(4.adjusted)
        }
    }
}
