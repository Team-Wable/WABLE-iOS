//
//  InfoNewsViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 11/24/24.
//

import UIKit
import Combine

import CombineCocoa
import Kingfisher

protocol InfoNewsViewControllerDelegate: AnyObject {
    func pushToNewsDetailView(with news: NewsDTO)
}

final class InfoNewsViewController: UIViewController {
    
    typealias Item = NewsDTO
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    enum Section: CaseIterable {
        case main
    }
    
    // MARK: - Property
    
    weak var delegate: InfoNewsViewControllerDelegate?
    
    private var dataSource: DataSource?
    
    private let viewModel: InfoNewsViewModel
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let collectionViewDidRefreshSubject = PassthroughSubject<Void, Never>()
    private let collectionViewDidSelectSubject = PassthroughSubject<Int, Never>()
    private let collectionViewDidEndDragSubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    private let rootView = InfoNewsView()
    
    // MARK: - Initializer

    init(viewModel: InfoNewsViewModel) {
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
        
        setupCollectionView()
        setupDataSource()
        setupAction()
        setupBinding()
        
        viewDidLoadSubject.send(())
    }
}

// MARK: - UICollectionViewDelegate

extension InfoNewsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewDidSelectSubject.send(indexPath.item)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == rootView.collectionView,
              (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height
        else {
            return
        }
        
        collectionViewDidEndDragSubject.send(())
    }
}

// MARK: - Private Method

private extension InfoNewsViewController {
    func setupCollectionView() {
        rootView.collectionView.setCollectionViewLayout(collectionViewLayout, animated: false)
        
        rootView.collectionView.delegate = self
        
        rootView.collectionView.register(
            NewsHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: NewsHeaderView.identifier
        )
    }
    
    func setupDataSource() {
        let newsCellRegistration = UICollectionView.CellRegistration<NewsCell, Item> { cell, indexPath, item in
            cell.titleLabel.text = item.title
            cell.bodyLabel.text = item.text
            cell.timeLabel.text = item.time
            
            guard let imageURLString = item.imageURLString else { return }
            cell.imageView.isHidden = false
            cell.imageView.kf.setImage(with: URL(string: imageURLString))
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: newsCellRegistration,
                for: indexPath,
                item: item
            )
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: NewsHeaderView.identifier,
                for: indexPath
            ) as? NewsHeaderView
        }
    }
    
    func applySnapshot(items: [Item], to section: Section) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: section)
        dataSource?.apply(snapshot)
    }
    
    func setupAction() {
        let refreshAction = UIAction { [weak self] _ in
            self?.collectionViewDidRefreshSubject.send(())
        }
        
        rootView.collectionView.refreshControl?.addAction(refreshAction, for: .valueChanged)
    }
    
    func setupBinding() {
        let input = InfoNewsViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            collectionViewDidRefresh: collectionViewDidRefreshSubject.eraseToAnyPublisher(),
            collectionViewDidSelect: collectionViewDidSelectSubject.eraseToAnyPublisher(),
            collectionViewDidEndDrag: collectionViewDidEndDragSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(from: input, cancelBag: cancelBag)
        
        output.news
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.endRefreshing()
            })
            .removeDuplicates()
            .sink { [weak self] news in
                self?.applySnapshot(items: news, to: .main)
                self?.rootView.collectionView.isHidden = news.isEmpty
                self?.rootView.emptyLabel.isHidden = !news.isEmpty
            }
            .store(in: cancelBag)
        
        output.selectedNews
            .receive(on: RunLoop.main)
            .sink { [weak self] news in
                self?.delegate?.pushToNewsDetailView(with: news)
            }
            .store(in: cancelBag)
    }
    
    func endRefreshing() {
        guard let refreshControl = rootView.collectionView.refreshControl,
                refreshControl.isRefreshing
        else {
            return
        }
        
        refreshControl.endRefreshing()
    }
}

private extension InfoNewsViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(94.adjustedH)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(75.adjustedH)
            )
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [headerItem]
            
            return section
        }
    }
}
