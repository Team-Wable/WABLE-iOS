//
//  LCKYearCollectionViewCell.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/20/25.
//


import UIKit

final class LCKYearCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UIComponent
    
    let yearLabel = UILabel().then {
        $0.attributedText = "\(Calendar.current.component(.year, from: Date()))".pretendardString(with: .body2)
        $0.textColor = .wableBlack
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = .clear
        yearLabel.textColor = .wableBlack
        yearLabel.attributedText = yearLabel.text?.pretendardString(with: .body2)
    }
}

// MARK: - Private Extension

private extension LCKYearCollectionViewCell {
    func setupView() {
        layer.cornerRadius = 8.adjustedHeight
        clipsToBounds = true
        
        contentView.addSubview(yearLabel)
    }
    
    func setupConstraint() {
        yearLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(9)
        }
    }
}

