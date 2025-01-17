//
//  MigratedDetailViewController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 1/16/25.
//

import UIKit
import Combine

import CombineCocoa

final class MigratedDetailViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Item: Hashable {
        case feed(HomeFeedDTO)
        case reply(FlattenReplyModel)
    }
    
    enum Section: CaseIterable {
        case feed
        case reply
    }
    
    // MARK: - Properties
    
    private var dataSource: DataSource?
    private let viewModel: MigratedDetailViewModel
    private let cancelBag = CancelBag()
    private let rootView = MigratedDetailView()
    
    // MARK: - Initializer
    
    init(viewModel: MigratedDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Private Method

private extension MigratedDetailViewController {
    func setupCollectionView() {
        rootView.collectionView.setCollectionViewLayout(collectionViewLayout, animated: false)
    }
    
    func setupDataSource() {
        let feedCellRegistration = UICollectionView.CellRegistration<MigratedHomeFeedCell, HomeFeedDTO> {
            cell, index, item in
            cell.bind(data: item)
        }
        
        let replyCellRegistration = UICollectionView.CellRegistration<MigratedDetailCell, FlattenReplyModel> {
            cell, index, item in
            cell.bind(data: item)
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            switch item {
            case .feed(let feedData):
                collectionView.dequeueConfiguredReusableCell(
                    using: feedCellRegistration,
                    for: indexPath,
                    item: feedData
                )
                
            case .reply(let replyData):
                collectionView.dequeueConfiguredReusableCell(
                    using: replyCellRegistration,
                    for: indexPath,
                    item: replyData
                )
            }
        }
    }
    
    func applySnapshot(items: [Item], to section: Section) {
        var snapshot = dataSource?.snapshot() ?? Snapshot()
        
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections(Section.allCases)
        }
        
        snapshot.appendItems(items, toSection: section)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func setupBinding() {
        let input = MigratedDetailViewModel.Input()
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
    }
}

private extension MigratedDetailViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = Section.allCases[sectionIndex]
            switch sectionKind {
            case .feed:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(170.adjustedH))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(170.adjusted))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                return section
            case .reply:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(150.adjustedH))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(150.adjusted))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                return section
            }
        }
    }
}
