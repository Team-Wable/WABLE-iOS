//
//  InfoNewsView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit

import SnapKit

final class InfoNewsView: UIView {    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        collectionView.refreshControl = UIRefreshControl()
        return collectionView
    }()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Info.noNewsText
        label.textColor = .gray500
        label.font = .body2
        label.textAlignment = .center
        label.isHidden = true
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

private extension InfoNewsView {
    func setupView() {
        addSubviews(collectionView, emptyLabel)
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
