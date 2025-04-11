//
//  CommunityView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/11/25.
//

import UIKit

import SnapKit
import Then

final class CommunityView: UIView {
    
    // MARK: - UIComponent
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    let askButton = WableButton(style: .black).then {
        var config = $0.configuration
        config?.attributedTitle = Constant.askButtonTitle
            .pretendardString(with: .body3)
            .highlight(textColor: .sky50, to: "요청하기")
        $0.configuration = config
    }
    
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

private extension CommunityView {
    func setupView() {
        backgroundColor = .wableWhite
        
        let statusBarBackgroundView = UIView(backgroundColor: .wableBlack)
        
        let navigationView = NavigationView(type: .hub(title: "커뮤니티", isBeta: true)).then {
            $0.configureView()
        }
        
        let underlineView = UIView(backgroundColor: .gray200)
        
        addSubviews(
            statusBarBackgroundView,
            navigationView,
            collectionView,
            askButton,
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
        }
        
        askButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(safeArea).offset(-16)
            make.adjustedHeightEqualTo(48)
        }
        
        underlineView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(safeArea)
            make.height.equalTo(1)
        }
    }
}

// MARK: - Computed Property

private extension CommunityView {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(96)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(96)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.adjustedHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - Constant

private extension CommunityView {
    enum Constant {
        static let askButtonTitle = "더 추가하고 싶은 게시판이 있다면? 요청하기"
    }
}
