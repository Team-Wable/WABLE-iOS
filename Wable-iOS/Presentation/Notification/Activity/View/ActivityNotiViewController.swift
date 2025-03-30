//
//  ActivityNotiViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/26/25.
//

import UIKit

import SnapKit
import Then

final class ActivityNotiViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section {
        case main
    }
    
    // MARK: - typealias

    typealias Item = ActivityNotification
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Property

    private var dataSource: DataSource?
    
    // MARK: - UIComponent

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let emptyLabel = UILabel().then {
        $0.attributedText = "아직 표시할 내용이 없습니다.".pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.isHidden = true
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
    }
}

// MARK: - Setup Method

private extension ActivityNotiViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            collectionView,
            emptyLabel
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupDataSource() {
        let cellRegistration = CellRegistration<NotificationCell, Item> { cell, indexPath, item in
            
            // TODO: Cell Configure
            
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
}

// MARK: - Helper Method

private extension ActivityNotiViewController {
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapshot)
    }
}

// MARK: - Computed Property

private extension ActivityNotiViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
