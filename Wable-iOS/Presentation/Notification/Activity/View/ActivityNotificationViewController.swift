//
//  ActivityNotificationViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 3/26/25.
//

import Combine
import UIKit
import SafariServices

import SnapKit
import Then

final class ActivityNotificationViewController: UIViewController {
    
    // MARK: - Section
    
    enum Section {
        case main
    }
    
    // MARK: - typealias

    typealias Item = ActivityNotification
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = ActivityNotificationViewModel
    
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
    private let didSelectItemSubject = PassthroughSubject<Int, Never>()
    private let willDisplayLastItemSubject = PassthroughSubject<Void, Never>()
    private let profileImageViewDidTapSubject = PassthroughSubject<Int, Never>()
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

extension ActivityNotificationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemSubject.send(indexPath.item)
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

private extension ActivityNotificationViewController {
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
        let profileInteractionTypes = TriggerType.ActivityNotification.profileInteractionTypes
        
        let cellRegistration = CellRegistration<NotificationCell, Item> { cell, indexPath, item in
            let content = item.targetContentText.isEmpty
            ? item.message
            : "\(item.message)\n : \(item.targetContentText.truncated(toLength: 15))"
            
            let time = item.time ?? .now
            
            cell.configure(imageURL: item.triggerUserProfileURL, content: content, time: time.elapsedText)
            
            if let triggerType = item.type,
               profileInteractionTypes.contains(triggerType) {
                cell.profileImageViewDidTapAction = { [weak self] in
                    self?.profileImageViewDidTapSubject.send(indexPath.item)
                }
            }
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
            didSelectItem: didSelectItemSubject.eraseToAnyPublisher(),
            willDisplayLastItem: willDisplayLastItemSubject.eraseToAnyPublisher(),
            profileImageViewDidTap: profileImageViewDidTapSubject.eraseToAnyPublisher()
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
        
        output.isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingMore in
                isLoadingMore ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            }
            .store(in: cancelBag)
        
        output.content
            .receive(on: DispatchQueue.main)
            .sink { contentID in
                WableLogger.log("게시물 ID: \(contentID)", for: .debug)
                
                let viewController = HomeDetailViewController(
                    viewModel: HomeDetailViewModel(
                        contentID: contentID,
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
                
                self.navigationController?.pushViewController(viewController, animated: true)
            }
            .store(in: cancelBag)
        
        output.writeContent
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
                // TODO: 게시물 작성하기로 이동
                
            }
            .store(in: cancelBag)
        
        output.googleForm
            .receive(on: DispatchQueue.main)
            .compactMap { URL(string: Constant.googleFormURLText) }
            .sink { [weak self] url in
                let safariController = SFSafariViewController(url: url)
                self?.present(safariController, animated: true)
            }
            .store(in: cancelBag)
        
        output.user
            .receive(on: DispatchQueue.main)
            .sink { userID in
                WableLogger.log("유저 아이디: \(userID)", for: .debug)
                
                // TODO: 유저 프로필로 이동
                
            }
            .store(in: cancelBag)
    }
}

// MARK: - Helper Method

private extension ActivityNotificationViewController {
    func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapshot)
    }
}

// MARK: - Action Method

private extension ActivityNotificationViewController {
    @objc func collectionViewDidRefresh() {
        didRefreshSubject.send()
    }
}

// MARK: - Computed Property

private extension ActivityNotificationViewController {
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

// MARK: - Constant

private extension ActivityNotificationViewController {
    enum Constant {
        static let googleFormURLText: String = "https://docs.google.com/forms/d/e/1FAIpQLSf3JlBkVRPaPFSreQHaEv-u5pqZWZzk7Y4Qll9lRP0htBZs-Q/viewform"
    }
}
