//
//  MigratedDetailView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/16/25.
//

import UIKit

import SnapKit

final class MigratedDetailView: UIView {
    
    // MARK: - UI Components
    
    private let topDivisionLine = UIView().makeDivisionLine()
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .wableWhite
        collectionView.refreshControl = UIRefreshControl()
        return collectionView
    }()
    var bottomWriteView = FeedBottomWriteView()
    
    // MARK: - Life Cycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions

extension MigratedDetailView {
    private func setUI() {
        self.backgroundColor = .wableWhite
        bottomWriteView.writeTextView.textContainerInset = UIEdgeInsets(top: 10.adjusted,
                                                                        left: 10.adjusted,
                                                                        bottom: 10.adjusted,
                                                                        right: 10.adjusted)
    }
    
    private func setHierarchy() {
        self.addSubviews(
            topDivisionLine,
            collectionView,
            bottomWriteView
        )
    }
    
    private func setLayout() {
        topDivisionLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.height.equalTo(1.adjusted)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topDivisionLine.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomWriteView.snp.top)
        }
        
        bottomWriteView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.lessThanOrEqualTo(120.adjusted)
        }
        
        keyboardLayoutGuide.topAnchor.constraint(equalToSystemSpacingBelow: bottomWriteView.bottomAnchor, multiplier: 1.0).isActive = true
    }
}
