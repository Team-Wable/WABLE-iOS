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
    
    private let loadingFooterIndicator = UIActivityIndicatorView(style: .large).then {
        $0.color = .gray600
    }
    
    // MARK: - Properties

    var openURL: ((URL) -> Void)?
    
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
                // TODO: - 추후 URL 이동 방식 변경 (코디네이터 이용)
                // self.openURL?()
            }
        }

        let footerRegistration = UICollectionView.SupplementaryRegistration<UICollectionReusableView>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] supplementaryView, _, _ in
            guard let self = self else { return }
            supplementaryView.backgroundColor = .clear
            supplementaryView.subviews.forEach { $0.removeFromSuperview() }

            if self.loadingFooterIndicator.superview !== supplementaryView {
                self.loadingFooterIndicator.removeFromSuperview()
                supplementaryView.addSubview(self.loadingFooterIndicator)
                self.loadingFooterIndicator.snp.makeConstraints { make in
                    make.verticalEdges.centerX.equalToSuperview()
                }
            }
            
            self.loadingFooterIndicator.isHidden = !self.loadingFooterIndicator.isAnimating
        }

        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(
                using: footerRegistration,
                for: indexPath
            )
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

        output.isLoadingMore
            .sink { [weak self] isLoadingMore in self?.setLoadingFooterAnimating(isLoadingMore) }
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

    func setLoadingFooterAnimating(_ isAnimating: Bool) {
        loadingFooterIndicator.isHidden = !isAnimating
        isAnimating ? loadingFooterIndicator.startAnimating() : loadingFooterIndicator.stopAnimating()
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
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(256.adjustedHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)

        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [footer]

        return UICollectionViewCompositionalLayout(section: section)
    }
}
