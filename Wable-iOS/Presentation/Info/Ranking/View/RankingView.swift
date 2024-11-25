//
//  RankingView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/29/24.
//

import UIKit

import SnapKit

final class RankingView: UIView {
    
    // MARK: - UI Component
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let submitOpinionButton: UIButton = {
        let button = UIButton()
        
        let fullText = StringLiterals.Info.submitOpinionButtonLongTitle
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [.font: UIFont.body3, .foregroundColor: UIColor.white]
        )
        
        let targetText = StringLiterals.Info.submitOpinionButtonLongTitle
        if let range = fullText.range(of: targetText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([.foregroundColor: UIColor.sky50], range: nsRange)
        }
        
        button.setAttributedTitle(attributedString, for: .normal)
        button.backgroundColor = .wableBlack
        button.layer.cornerRadius = 12.adjusted
        return button
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

private extension RankingView {
    func setupView() {
        backgroundColor = .wableWhite
    
        addSubviews(
            collectionView,
            submitOpinionButton
        )
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        submitOpinionButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(48.adjustedH)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
