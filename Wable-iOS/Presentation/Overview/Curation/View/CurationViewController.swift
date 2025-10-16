//
//  CurationViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 10/16/25.

import UIKit
import Combine

import SnapKit
import Then

final class CurationViewController: UIViewController {

    // MARK: - Section Enum
    
    private enum Section {
        case main
    }

    // MARK: - Typealias
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, CurationItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CurationItem>

    // MARK: - UIComponents

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: CurationViewController.collectionViewLayout
    ).then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
    }

    private let refreshControl = UIRefreshControl()

    private let emptyLabel = UILabel().then {
        $0.attributedText = Constants.emptyDescription.pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.textAlignment = .center
    }
    
    // MARK: - Properties

    private var dataSource: DataSource?

    private let viewModel: CurationViewModel
    private let loadSubject = PassthroughSubject<Void, Never>()
    private let loadMoreSubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()

    // MARK: - Life Cycle

    init(viewModel: CurationViewModel = .init()) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupLayout()
        setupDataSource()
        setupAction()
        setupBinding()
        
        loadSubject.send()
    }

    @objc private func handleRefresh() {
        loadSubject.send()
    }
}

// MARK: - UICollectionViewDelegate

extension CurationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let itemCount = dataSource?.snapshot().numberOfItems,
              indexPath.item >= itemCount - 3
        else {
            return
        }
        
        loadMoreSubject.send()
    }
}

// MARK: - Setup Methods

private extension CurationViewController {
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubviews(
            collectionView,
            emptyLabel
        )

        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
    }

    func setupAction() {
//        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)

        refreshControl.publisher(for: .valueChanged)
            .sink { [weak self] _ in
                self?.loadSubject.send()
            }
            .store(in: cancelBag)
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CurationCell, CurationItem> { cell, indexPath, item in
            cell.configure(
                time: item.time,
                thumbnailURL: item.thumbnailURL,
                title: item.title,
                source: item.source
            ) {
                UIApplication.shared.open(URL(string: "https://www.naver.com")!)
            }
        }

        let footerRegistration = UICollectionView.SupplementaryRegistration<UICollectionReusableView>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.backgroundColor = .clear
            
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = .gray600
            indicator.startAnimating()
            
            supplementaryView.subviews.forEach { $0.removeFromSuperview() }
            supplementaryView.addSubview(indicator)
            
            indicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }

    func setupBinding() {
        let input = CurationViewModel.Input(
            load: loadSubject.eraseToAnyPublisher(),
            loadMore: loadMoreSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.items
            .sink { [weak self] items in
                self?.applySnapshot(items: items)
                self?.emptyLabel.isHidden = !items.isEmpty
            }
            .store(in: cancelBag)

        output.isLoading
            .filter { !$0 }
            .sink { [weak self] _ in self?.refreshControl.endRefreshing() }
            .store(in: cancelBag)
    }
}

// MARK: - Helper Methods

private extension CurationViewController {
    func applySnapshot(items: [CurationItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Constants

private extension CurationViewController {
    enum Constants {
        static let emptyDescription = "아직 추천된 콘텐츠가 없어요."
    }
}

// MARK: - UICollectionViewCompositionalLayout

private extension CurationViewController {
    static var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(256)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(256)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        
//        let footerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(60)
//        )
//        let footer = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: footerSize,
//            elementKind: UICollectionView.elementKindSectionFooter,
//            alignment: .bottom
//        )
//        section.boundarySupplementaryItems = [footer]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
