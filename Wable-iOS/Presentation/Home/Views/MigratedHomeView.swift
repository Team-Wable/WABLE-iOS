//
//  MigratedHomeView.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 12/24/24.
//

import UIKit

import SnapKit

final class MigratedHomeView: UIView {
    
    // MARK: - UI Components
    
    private let homeTabView = HomeTabView()
    let loadingView = HomeLoadingView()
    let writeFeedButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.Button.btnWrite, for: .normal)
        return button
    }()
    
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

extension MigratedHomeView {
    private func setUI() {
        backgroundColor = .wableWhite
        loadingView.isHidden = true
    }
    
    private func setHierarchy() {
        self.addSubviews(homeTabView,
                         collectionView,
                         writeFeedButton,
                         loadingView)
    }
    
    private func setLayout() {
        loadingView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height)
        }
        
        homeTabView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(homeTabView.snp.bottom).offset(-2)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        writeFeedButton.snp.makeConstraints {
            $0.height.width.equalTo(60.adjusted)
            $0.bottom.trailing.equalToSuperview().inset(16.adjusted)
        }
    }
}
