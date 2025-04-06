//
//  HomeDetailViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/31/25.
//

import Combine
import UIKit

final class HomeDetailViewController: NavigationViewController {
    
    // MARK: - Section
    
    enum Section: Hashable, CaseIterable {
        case content
        case comment
    }
    
    // MARK: - Item
    
    enum Item: Hashable {
        case content(Content)
        case comment(ContentComment)
    }
    
    // MARK: - typealias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    private let viewModel: HomeDetailViewModel
    private let willAppearSubject = PassthroughSubject<Void, Never>()
    private let didRefreshSubject = PassthroughSubject<Void, Never>()
    private let didHeartTappedSubject = PassthroughSubject<(Int, Bool), Never>()
    private let willDisplayLastItemSubject = PassthroughSubject<Void, Never>()
    private let cancelBag: CancelBag
    
    // MARK: - UIComponent
    
    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    // MARK: - LifeCycle
    
    init(viewModel: HomeDetailViewModel, cancelBag: CancelBag) {
        self.viewModel = viewModel
        self.cancelBag = cancelBag
        
        super.init(type: .page(type: .detail, title: "게시글"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDataSource()
        setupBinding()
    }
}

// MARK: - Setup Extension

private extension HomeDetailViewController {
    func setupView() {
        view.addSubview(collectionView)
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupDataSource() {
        let contentCellRegistration = UICollectionView.CellRegistration<ContentCollectionViewCell, Content> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            
            cell.configureCell(info: item.content.contentInfo, postType: .mine, likeButtonTapHandler: {
                self.didHeartTappedSubject.send((item.content.id, cell.likeButton.isLiked))
            })
        }
        
        let commentCellRegistration = UICollectionView.CellRegistration<CommentCollectionViewCell, ContentComment> { cell, indexPath, item in
            cell.configureCell(info: item.comment, commentType: .ripple, postType: .mine)
        }
        
        dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            let section = Section.allCases[indexPath.section]
            switch (section, item) {
            case (.content, .content(let content)):
                return collectionView.dequeueConfiguredReusableCell(using: contentCellRegistration, for: indexPath, item: content)
            case (.comment, .comment(let comment)):
                return collectionView.dequeueConfiguredReusableCell(using: commentCellRegistration, for: indexPath, item: comment)
            default:
                return nil
            }
        }
        
        var snapshot = Snapshot()
        
        snapshot.appendSections([.content, .comment])
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func setupBinding() {
        
    }
}

// MARK: - Computed Property

private extension HomeDetailViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            
            let section = Section.allCases[sectionIndex]
            switch section {
            case .content:
                return self.createSection(estimatedHeight: 500, topInset: 0)
            case .comment:
                return self.createSection(estimatedHeight: 300, topInset: 10)
            }
        }
    }

    private func createSection(estimatedHeight: CGFloat, topInset: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(estimatedHeight)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(estimatedHeight)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: topInset, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }
}

// MARK: - Update Data Methods

extension HomeDetailViewController {
    func updateContent(_ content: Content) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .content))
        snapshot.appendItems([.content(content)], toSection: .content)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func updateComments(_ comments: [ContentComment]) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        let commentItems = comments.map { Item.comment($0) }
        
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .comment))
        snapshot.appendItems(commentItems, toSection: .comment)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
