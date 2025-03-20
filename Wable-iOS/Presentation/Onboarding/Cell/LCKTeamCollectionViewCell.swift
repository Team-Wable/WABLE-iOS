//
//  LCKTeamCollectionViewCell.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

final class LCKTeamCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    private let teamImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let teamLabel: UILabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Extension

private extension LCKTeamCollectionViewCell {
    func setupView() {
        layer.cornerRadius = 32.adjustedHeight
        clipsToBounds = true
        
        contentView.addSubviews(teamLabel, teamImageView)
    }
    
    func setupConstraint() {
        teamImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
        }
        
        teamLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(teamImageView.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
