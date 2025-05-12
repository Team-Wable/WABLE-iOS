//
//  ViewitListView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/12/25.
//

import UIKit

import SnapKit
import Then

final class ViewitListView: UIView {
    
    // MARK: - UIComponent
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    let emptyLabel = UILabel().then {
        $0.attributedText = "아직 작성된 글이 없어요".pretendardString(with: .body2)
        $0.textColor = .gray500
    }
    
    let createButton = UIButton().then {
        $0.setImage(.btnWrite, for: .normal)
    }
    
    let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .gray600
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Method

private extension ViewitListView {
    func setupView() {
        backgroundColor = .wableWhite
        
        let statusBarBackgroundView = UIView(backgroundColor: .wableBlack)
        let navigationView = NavigationView(type: .hub(title: "뷰잇", isBeta: false)).then {
            $0.configureView()
        }
        let underlineView = UIView(backgroundColor: .gray200)
        
        addSubviews(
            statusBarBackgroundView,
            navigationView,
            collectionView,
            emptyLabel,
            createButton,
            loadingIndicator,
            underlineView
        )
        
        statusBarBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea.snp.top)
        }
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(60)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(underlineView.snp.top)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(safeArea)
        }
        
        createButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalTo(safeArea).offset(-24)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        underlineView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(safeArea)
            make.height.equalTo(1)
        }
    }
}

// MARK: - Computed Property

private extension ViewitListView {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(228)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(228)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
