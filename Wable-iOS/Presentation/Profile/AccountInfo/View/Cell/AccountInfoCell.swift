//
//  AccountInfoCell.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/12/25.
//

import UIKit

import SnapKit
import Then

final class AccountInfoCell: UICollectionViewCell {
    
    private let titleLabel = UILabel().then {
        $0.attributedText = "제목".pretendardString(with: .body2)
        $0.textColor = .gray600
    }
    
    private let descriptionLabel = UILabel().then {
        $0.attributedText = "본문".pretendardString(with: .body2)
        $0.textColor = .wableBlack
    }
    
    private var userInteractionClosure: VoidClosure?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, description: String, userInteraction: (() -> Void)? = nil) {
        titleLabel.text = title
        
        guard let userInteraction else {
            descriptionLabel.text = description
            return
        }
        
        userInteractionClosure = userInteraction
        descriptionLabel.attributedText = description.pretendardString(with: .body2).addUnderline()
        
        descriptionLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(descriptionDidTap))
        descriptionLabel.addGestureRecognizer(tapGesture)
    }
}

private extension AccountInfoCell {
    func setupCell() {
        contentView.addSubviews(titleLabel, descriptionLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.leading.equalToSuperview().offset(160)
            make.trailing.equalToSuperview().offset(-24)
        }
    }
    
    @objc func descriptionDidTap() {
        userInteractionClosure?()
    }
}
