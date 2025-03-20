//
//  LCKTeamCollectionViewCell.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

final class LCKTeamCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    let teamImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    let teamLabel: UILabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .pretendard(.body1)
    }
    
    // MARK: - LifeCycle
    
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
        layer.cornerRadius = 32.adjustedWidth
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray300.cgColor
        layer.masksToBounds = true
        
        contentView.addSubviews(teamLabel, teamImageView)
    }
    
    func setupConstraint() {
        teamImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.adjustedWidthEqualTo(44)
            $0.adjustedHeightEqualTo(44)
        }
        
        teamLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(teamImageView.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
