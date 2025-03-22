//
//  GameTypeCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/20/25.
//

import UIKit

import SnapKit
import Then

final class GameTypeCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    private let titleLabel = UILabel().then {
        $0.textColor = .purple100
    }

    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Method

extension GameTypeCell {
    func configure(gameType: String) {
        titleLabel.attributedText = gameType.pretendardString(with: .body3)
    }
}

// MARK: - Setup Method

private extension GameTypeCell {
    func setupView() {
        backgroundColor = .purple10
        layer.cornerRadius = 8
        
        contentView.addSubview(titleLabel)
    }
    
    func setupConstriant() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
