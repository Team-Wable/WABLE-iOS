//
//  SessionCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit

import SnapKit

final class SessionCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Info.lckSummer
        label.font = .body3
        label.textColor = .purple100
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

private extension SessionCell {
    func setupView() {
        backgroundColor = .purple10
        layer.cornerRadius = 8.adjusted
        
        contentView.addSubview(titleLabel)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
