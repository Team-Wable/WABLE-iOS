//
//  MyProfileView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit

import SnapKit
import Then

final class MyProfileView: UIView {
    let navigationView = NavigationView(type: .page(type: .profile, title: "이름"))
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .gray600
    }
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .wableWhite
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MyProfileView {
    func setupView() {
        let underlineView = UIView(backgroundColor: .gray200)
        
        addSubviews(navigationView, collectionView, loadingIndicator, underlineView)
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(56)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea)
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
