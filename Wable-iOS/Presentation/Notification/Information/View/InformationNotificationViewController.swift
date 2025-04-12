//
//  InformationNotificationViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/29/25.
//

import Combine
import UIKit

import SnapKit
import Then

final class InformationNotificationViewController: UIViewController {
    
    // MARK: - Section

    enum Section {
        case main
    }
    
    // MARK: - typealias
    
    typealias Item = InformationNotification
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = InformationNotificationViewModel
    
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
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .gray600
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let viewModel: ViewModel
    private let didLoadSubject = PassthroughSubject<Void, Never>()
    private let didRefreshSubject = PassthroughSubject<Void, Never>()
    private let didSelectSubject = PassthroughSubject<Int, Never>()
    private let willDisplayLastItemSubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDataSource()
        setupAction()
        setupDelegate()
        setupBinding()
        
        didLoadSubject.send()
    }
}

// MARK: - UICollectionViewDelegate

extension InformationNotificationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectSubject.send(indexPath.item)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemCount = dataSource?.snapshot().itemIdentifiers.count,
              itemCount > .zero
        else {
            return
        }
        
        if indexPath.item >= itemCount - 5 {
            willDisplayLastItemSubject.send()
        }
    }
}

// MARK: - Setup Method

private extension InformationNotificationViewController {
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(
            collectionView,
            emptyLabel,
            loadingIndicator
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func setupDataSource() {
        let cellRegistration = CellRegistration<NotificationCell, Item> { cell, _, item in
            let date = item.time ?? .now
            cell.configure(
                imageURL: item.imageURL,
                content: item.type?.message ?? "",
                time: date.elapsedText
            )
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func setupAction() {
        collectionView.refreshControl?.addTarget(self, action: #selector(collectionViewDidRefresh), for: .valueChanged)
    }
    
    func setupDelegate() {
        collectionView.delegate = self
    }
    
    func setupBinding() {
        let input = ViewModel.Input(
            viewDidLoad: didLoadSubject.eraseToAnyPublisher(),
            viewDidRefresh: didRefreshSubject.eraseToAnyPublisher(),
            didSelectItem: didSelectSubject.eraseToAnyPublisher(),
            willDisplayLastItem: willDisplayLastItemSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard !isLoading else { return }
                self?.collectionView.refreshControl?.endRefreshing()
            }
            .store(in: cancelBag)
        
        output.notifications
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.applySnapshot(items: items)
                self?.emptyLabel.isHidden = !items.isEmpty
            }
            .store(in: cancelBag)
        
        output.selectedNotification
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                let viewController = HomeDetailViewController(
                    viewModel: HomeDetailViewModel(
                        contentID: item.id,
                        contentTitle: "",
                        fetchContentInfoUseCase: FetchContentInfoUseCase(repository: ContentRepositoryImpl()),
                        createContentLikedUseCase: CreateContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
                        deleteContentLikedUseCase: DeleteContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
                        fetchContentCommentListUseCase: FetchContentCommentListUseCase(repository: CommentRepositoryImpl()),
                        createCommentUseCase: CreateCommentUseCase(repository: CommentRepositoryImpl()),
                        deleteCommentUseCase: DeleteCommentUseCase(repository: CommentRepositoryImpl()),
                        createCommentLikedUseCase: CreateCommentLikedUseCase(repository: CommentLikedRepositoryImpl()),
                        deleteCommentLikedUseCase: DeleteCommentLikedUseCase(repository: CommentLikedRepositoryImpl())
                    ),
                    cancelBag: CancelBag()
                )
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            .store(in: cancelBag)
        
        output.isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingMore in
                isLoadingMore ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            }
            .store(in: cancelBag)
    }
}

// MARK: - Helper Method

private extension InformationNotificationViewController {
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapshot)
    }
}

// MARK: - Action Method

private extension InformationNotificationViewController {
    @objc func collectionViewDidRefresh() {
        didRefreshSubject.send()
    }
}

// MARK: - Computed Property

private extension InformationNotificationViewController {
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
