//
//  CommunityView.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/11/25.
//

import Combine
import UIKit

import SnapKit
import Then

final class CommunityView: UIView {
    
    // MARK: - UIComponent
    
    private let statusBarBackgroundView = UIView(backgroundColor: .wableBlack)
    
    private let navigationView = NavigationView(type: .hub(title: "커뮤니티", isBeta: true))
    
    lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.alwaysBounceVertical = true
    }
    
    let refreshControl = UIRefreshControl()
    
    let askButton = WableButton(style: .black).then {
        var config = $0.configuration
        config?.attributedTitle = StringLiterals.Community.askButtonTitle
            .pretendardString(with: .body3)
            .highlight(textColor: .sky50, to: "요청하기")
        $0.configuration = config
    }
    
    private let underlineView = UIView(backgroundColor: .gray200)
    
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

extension CommunityView {
    var askDidTap: AnyPublisher<Void, Never> { askButton.publisher(for: .touchUpInside).eraseToAnyPublisher() }
    var didRefresh: AnyPublisher<Void, Never> { refreshControl.publisher(for: .valueChanged).eraseToAnyPublisher() }
}

private extension CommunityView {
    
    // MARK: - Setup Method
    
    func setupView() {
        backgroundColor = .wableWhite
        
        collectionView.refreshControl = refreshControl
        
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
    
    // MARK: - CollectionViewLayout

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
