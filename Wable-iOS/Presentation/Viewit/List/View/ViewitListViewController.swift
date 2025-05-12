//
//  ViewitListViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 4/12/25.
//

import UIKit
import SafariServices

final class ViewitListViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section {
        case main
    }
    
    // MARK: - typealias
    
    typealias Item = Viewit
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = ViewitListViewModel
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let viewModel: ViewModel
    private let didLoadRelay = PassthroughRelay<Void>()
    private let etcRelay = PassthroughRelay<Int>()
    private let likeRelay = PassthroughRelay<Int>()
    private let willLastDisplayRelay = PassthroughRelay<Void>()
    private let cancelBag = CancelBag()
    private let rootView = ViewitListView()
    
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
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        setupDataSource()
        setupAction()
        setupDelegate()
        setupBinding()
        
        didLoadRelay.send()
    }
}

// MARK: - UICollectionViewDelegate

extension ViewitListViewController: UICollectionViewDelegate {
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
        
        if indexPath.item >= itemCount - 2 {
            willLastDisplayRelay.send()
        }
    }
}


// MARK: - CreateViewitViewDelegate

extension ViewitListViewController: CreateViewitViewDelegate {
    func finishCreateViewit() {
        didLoadRelay.send()
    }
}

// MARK: - Setup Method

private extension ViewitListViewController {
    func setupDataSource() {
        let cellRegistration = CellRegistration<ViewitCell, Item> { cell, indexPath, item in
            cell.configure(profileImageURL: item.userProfileURL, username: item.userNickname)
            cell.configure(
                viewitText: item.text,
                videoThumbnailImageURL: item.thumbnailURL,
                videoTitle: item.title,
                siteName: item.linkURL?.absoluteString ?? "",
                isLiked: item.like.status,
                likeCount: item.like.count,
                isBlind: item.status == .blind
            )
            
            cell.profileInfoDidTapClosure = {
                WableLogger.log("프로필 정보 눌림", for: .debug)
                
                // TODO: 프로필(상대/나)로 이동
            }
            
            cell.etcDidTapClosure = { [weak self] in
                WableLogger.log("점점점 눌림", for: .debug)
                self?.etcRelay.send(indexPath.item)
            }
            
            cell.cardDidTapClosure = { [weak self] in
                guard let url = item.linkURL else { return }
                self?.present(SFSafariViewController(url: url), animated: true)
            }
            
            cell.likeDidTap = { [weak self] in
                self?.likeRelay.send(indexPath.item)
            }
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
    
    func setupAction() {
        createButton.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
        refreshControl?.addTarget(self, action: #selector(viewDidRefresh), for: .valueChanged)
    }
    
    func setupDelegate() {
        rootView.collectionView.delegate = self
    }
    
    func setupBinding() {
        let input = ViewModel.Input(
            load: didLoadRelay.eraseToAnyPublisher(),
            like: likeRelay.eraseToAnyPublisher(),
            willLastDisplay: willLastDisplayRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.isLoading
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.refreshControl?.endRefreshing()
            }
            .store(in: cancelBag)
        
        output.viewitList
            .sink { [weak self] items in
                self?.rootView.emptyLabel.isHidden = !items.isEmpty
                self?.applySnapshot(items: items)
            }
            .store(in: cancelBag)
        
        output.isMoreLoading
            .sink { [weak self] isMoreLoading in
                let loadingIndicator = self?.rootView.loadingIndicator
                isMoreLoading ? loadingIndicator?.startAnimating() : loadingIndicator?.stopAnimating()
            }
            .store(in: cancelBag)
        
        output.errorMessage
            .sink { [weak self] message in
                let alertController = UIAlertController(
                    title: "오류가 발생했어요.",
                    message: message,
                    preferredStyle: .alert
                )
                let confirmAction = UIAlertAction(title: "확인", style: .default)
                alertController.addAction(confirmAction)
                self?.present(alertController, animated: true)
            }
            .store(in: cancelBag)
    }
    
    // MARK: - Helper Method
    
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot)
    }
    
    // MARK: - Action Method

    @objc func createButtonDidTap() {
        let useCase = CreateViewitUseCaseImpl()
        let writeViewController = CreateViewitViewController(viewModel: .init(useCase: useCase))
        present(writeViewController, animated: true)
    }
    
    @objc func viewDidRefresh() {
        didLoadRelay.send()
    }
    
    // MARK: - Computed Property
    
    var collectionView: UICollectionView { rootView.collectionView }
    var refreshControl: UIRefreshControl? { rootView.collectionView.refreshControl }
    var createButton: UIButton { rootView.createButton }
}
