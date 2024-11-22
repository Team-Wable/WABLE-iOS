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
    
    let sessionView: UIView = {
        let view = UIView()
        view.backgroundColor = .purple10
        view.layer.cornerRadius = 8.adjusted
        view.clipsToBounds = true
        return view
    }()
    
    let sessionLabel: UILabel = {
       let label = UILabel()
        label.text = StringLiterals.Info.lckSummer
        label.font = .body3
        label.textColor = .purple100
        label.textAlignment = .center
        return label
    }()
    
    let descriptionView = RankDescriptionView()
    
    private(set) lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    )
    
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
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40.adjusted)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40.adjusted)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func setupView() {
        backgroundColor = .wableWhite
        
        sessionView.addSubviews(sessionLabel)
        addSubviews(
            sessionView,
            descriptionView,
            collectionView
        )
    }
    
    func setupConstraints() {
        sessionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(40.adjustedH)
        }
        
        sessionLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        descriptionView.snp.makeConstraints { make in
            make.top.equalTo(sessionView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(36.adjustedH)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionView.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
}
