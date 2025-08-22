//
//  HomeViewController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/10/25.
//


import Combine
import UIKit

final class HomeViewController: NavigationViewController {

    // MARK: - Section
    
    enum Section: Hashable {
        case main
    }
    
    // MARK: - typealias
    
    typealias Item = Content
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - Property
    
    var shouldShowLoadingScreen: Bool = false
    private static var hasShownLoadingScreen = false
    
    private let viewModel: HomeViewModel
    private let willAppearSubject = PassthroughSubject<Void, Never>()
    private let didRefreshSubject = PassthroughSubject<Void, Never>()
    private let didSelectedSubject = PassthroughSubject<Int, Never>()
    private let didHeartTappedSubject = PassthroughSubject<(Int, Bool), Never>()
    private let didGhostTappedSubject = PassthroughSubject<(Int, Int, String?), Never>()
    private let didDeleteTappedSubject = PassthroughSubject<Int, Never>()
    private let didBannedTappedSubject = PassthroughSubject<(Int, Int), Never>()
    private let didReportTappedSubject = PassthroughSubject<(String, String), Never>()
    private let willDisplayLastItemSubject = PassthroughSubject<Void, Never>()
    private let cancelBag: CancelBag
    
    private var activeUserID: Int?
    private var isActiveUserAdmin: Bool?
    private var dataSource: DataSource?
    
    // MARK: - UIComponent
    
    private lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private lazy var plusButton: UIButton = .init(configuration: .plain()).then {
        $0.configuration?.image = .btnWrite
    }
    
    private let emptyLabel: UILabel = UILabel().then {
        $0.attributedText = StringLiterals.Empty.post.pretendardString(with: .body2)
        $0.textColor = .gray500
        $0.isHidden = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .gray600
    }
    
    private let divisionLine = UIView(backgroundColor: .gray200)
    
    // MARK: - LifeCycle
    
    init(viewModel: HomeViewModel, cancelBag: CancelBag) {
        self.viewModel = viewModel
        self.cancelBag = cancelBag
        
        super.init(type: .home(hasNewNotification: false))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraint()
        setupDataSource()
        setupAction()
        setupDelegate()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldShowLoadingScreen && !HomeViewController.hasShownLoadingScreen {
            showLoadingScreen()
            HomeViewController.hasShownLoadingScreen = true
        }
      
        willAppearSubject.send()
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectedSubject.send(indexPath.item)
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

private extension HomeViewController {
    func setupView() {
        navigationController?.navigationBar.isHidden = true
        
        view.addSubviews(
            collectionView,
            plusButton,
            emptyLabel,
            loadingIndicator,
            divisionLine
        )
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(16)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        divisionLine.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(1)
        }
    }
    
    func setupDataSource() {
        let homeCellRegistration = CellRegistration<ContentCollectionViewCell, Content> {
            [weak self] cell, indexPath, item in
            guard let self = self else { return }
            
            cell.configureCell(
                info: item,
                authorType: item.author.id == self.activeUserID ? .mine : .others,
                cellType: .list,
                contentImageViewTapHandler: {
                    guard let image = cell.contentImageView.image else {
                        return
                    }
                    
                    self.navigationController?.pushViewController(PhotoDetailViewController(image: image), animated: true)
                },
                likeButtonTapHandler: {
                    AmplitudeManager.shared.trackEvent(tag: .clickLikePost)
                    
                    self.didHeartTappedSubject.send((item.id, cell.likeButton.isLiked))
                },
                settingButtonTapHandler: {
                    let viewController = WableBottomSheetController()
                    
                    if self.activeUserID == item.author.id {
                        viewController.addActions(WableBottomSheetAction(title: "삭제하기", handler: {
                            viewController.dismiss(animated: true, completion: {
                                let viewController = WableSheetViewController(title: StringLiterals.Delete.contentSheetTitle, message: StringLiterals.Delete.contentSheetMessage)
                                
                                viewController.addActions(
                                    WableSheetAction(title: "취소", style: .gray),
                                    WableSheetAction(
                                        title: "삭제하기",
                                        style: .primary,
                                        handler: {
                                            AmplitudeManager.shared.trackEvent(tag: .clickDeletePost)
                                            
                                            viewController.dismiss(animated: true, completion: {
                                                self.didDeleteTappedSubject.send(item.id)
                                            })
                                        }
                                    )
                                )
                                
                                self.present(viewController, animated: true)
                            })
                        }))
                    } else if self.isActiveUserAdmin ?? false {
                        let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                            self?.showReportSheet(
                                onPrimary: { message in
                                    viewController.dismiss(
                                        animated: true,
                                        completion: {
                                            self?.didReportTappedSubject.send(
                                                (
                                                    item.author.nickname,
                                                    message ?? item.text
                                                )
                                            )
                                        })
                                })
                        }
                        let banAction = WableBottomSheetAction(title: "밴하기") { [weak self] in
                            self?.didBannedTappedSubject.send((item.author.id, item.id))
                        }
                        self.showBottomSheet(actions: reportAction, banAction)
                    } else {
                        let reportAction = WableBottomSheetAction(title: "신고하기") { [weak self] in
                            self?.showReportSheet(
                                onPrimary: { message in
                                    viewController.dismiss(
                                        animated: true,
                                        completion: {
                                            self?.didReportTappedSubject.send(
                                                (
                                                    item.author.nickname,
                                                    message ?? item.text
                                                )
                                            )
                                        })
                                })
                        }
                        self.showBottomSheet(actions: reportAction)
                    }
                    
                    self.present(viewController, animated: true)
                },
                profileImageViewTapHandler: { [weak self] in
                    guard let self = self else { return }
                    
                    if self.activeUserID == item.author.id,
                       let tabBarController = self.tabBarController {
                        tabBarController.selectedIndex = 4
                    } else {
                        let viewController = OtherProfileViewController(
                            viewModel: .init(
                                userID: item.author.id,
                                fetchUserProfileUseCase: FetchUserProfileUseCaseImpl(),
                                checkUserRoleUseCase: CheckUserRoleUseCaseImpl(
                                    repository: UserSessionRepositoryImpl(
                                        userDefaults: .init(
                                            jsonEncoder: .init(),
                                            jsonDecoder: .init()
                                        )
                                    )
                                )
                            )
                        )
                        
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                },
                ghostButtonTapHandler: {
                    AmplitudeManager.shared.trackEvent(tag: .clickGhostPost)
                    self.showGhostSheet(onCancel: {
                        AmplitudeManager.shared.trackEvent(tag: .clickWithdrawghostPopup)
                    }, onPrimary: { message in
                        AmplitudeManager.shared.trackEvent(tag: .clickApplyghostPopup)
                        self.didGhostTappedSubject.send((item.id, item.author.id, message))
                    })
                }
            )
        }
        
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: homeCellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func setupAction() {
        collectionView.refreshControl?.addAction(UIAction(handler: { [weak self] _ in
            self?.didRefreshSubject.send()
        }), for: .valueChanged)
        plusButton.addTarget(self, action: #selector(plusButtonDidTap), for: .touchUpInside)
        navigationView.notificationButton.addAction(
            UIAction(
                handler: { _ in
                    AmplitudeManager.shared.trackEvent(tag: .clickNotiBotnavi)
                    
                    let viewController = NotificationPageViewController()
                    
                    self.navigationController?.pushViewController(viewController, animated: true)
                }),
            for: .touchUpInside
        )
    }
    
    func setupDelegate() {
        collectionView.delegate = self
    }
    
    func setupBinding() {
        let input = HomeViewModel.Input(
            viewWillAppear: willAppearSubject.eraseToAnyPublisher(),
            viewDidRefresh: didRefreshSubject.eraseToAnyPublisher(),
            didSelectedItem: didSelectedSubject.eraseToAnyPublisher(),
            didHeartTappedItem: didHeartTappedSubject.eraseToAnyPublisher(),
            didGhostTappedItem: didGhostTappedSubject.eraseToAnyPublisher(),
            didDeleteTappedItem: didDeleteTappedSubject.eraseToAnyPublisher(),
            didBannedTappedItem: didBannedTappedSubject.eraseToAnyPublisher(),
            didReportTappedItem: didReportTappedSubject.eraseToAnyPublisher(),
            willDisplayLastItem: willDisplayLastItemSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.isAdmin
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAdmin in
                self?.isActiveUserAdmin = isAdmin
            }
            .store(in: cancelBag)
        
        output.badgeCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                guard let self = self,
                      let count = count
                else {
                    return
                }
                
                self.navigationView.updateNotificationStatus(hasNewNotification: count > 0)
            }
            .store(in: cancelBag)
        
        output.activeUserID
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                self?.activeUserID = id
            }
            .store(in: cancelBag)
        
        output.contents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] contents in
                self?.applySnapshot(items: contents)
                self?.emptyLabel.isHidden = !contents.isEmpty
            }
            .store(in: cancelBag)
        
        output.selectedContent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                let viewController = HomeDetailViewController(
                    viewModel: HomeDetailViewModel(
                        contentID: content.id,
                        fetchContentInfoUseCase: FetchContentInfoUseCase(repository: ContentRepositoryImpl()),
                        fetchContentCommentListUseCase: FetchContentCommentListUseCase(repository: CommentRepositoryImpl()),
                        createCommentUseCase: CreateCommentUseCase(repository: CommentRepositoryImpl()),
                        deleteCommentUseCase: DeleteCommentUseCase(repository: CommentRepositoryImpl()),
                        createContentLikedUseCase: CreateContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
                        deleteContentLikedUseCase: DeleteContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
                        createCommentLikedUseCase: CreateCommentLikedUseCase(repository: CommentLikedRepositoryImpl()),
                        deleteCommentLikedUseCase: DeleteCommentLikedUseCase(repository: CommentLikedRepositoryImpl()),
                        fetchUserInformationUseCase: FetchUserInformationUseCase(
                            repository: UserSessionRepositoryImpl(
                                userDefaults: UserDefaultsStorage(
                                    jsonEncoder: JSONEncoder(),
                                    jsonDecoder: JSONDecoder()
                                )
                            )
                        ),
                        fetchGhostUseCase: FetchGhostUseCase(repository: GhostRepositoryImpl()),
                        createReportUseCase: CreateReportUseCase(repository: ReportRepositoryImpl()),
                        createBannedUseCase: CreateBannedUseCase(repository: ReportRepositoryImpl()),
                        deleteContentUseCase: DeleteContentUseCase(repository: ContentRepositoryImpl())
                    ),
                    cancelBag: CancelBag()
                )
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            .store(in: cancelBag)
        
        output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            }
            .store(in: cancelBag)
        
        output.isLoadingMore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingMore in
                isLoadingMore ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            }
            .store(in: cancelBag)
        
        output.isReportSucceed
            .receive(on: DispatchQueue.main)
            .sink { isSucceed in
                let toast = ToastView(
                    status: .complete,
                    message: StringLiterals.Report.completeToast
                )
                
                isSucceed ? toast.show() : nil
            }
            .store(in: cancelBag)
    }
}

// MARK: - Helper Method

extension HomeViewController {
    private func applySnapshot(items: [Item]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        
        dataSource?.apply(snapshot)
        collectionView.reloadData()
    }
    
    func scrollToTop() {
        collectionView.setContentOffset(.zero, animated: true)
    }
    
    func showLoadingScreen() {
        let loadingController = LoadingViewController()
        present(loadingController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                loadingController.dismiss(animated: false)
            }
        }
    }
}

// MARK: - Action Method

private extension HomeViewController {
    @objc func plusButtonDidTap() {
        AmplitudeManager.shared.trackEvent(tag: .clickWritePost)
        
        let viewController = WritePostViewController(
            viewModel: WritePostViewModel(
                createContentUseCase: CreateContentUseCase(
                    repository: ContentRepositoryImpl()
                )
            )
        )
        
        viewController.onPostCompleted = { [weak self] in
            self?.scrollToTop()
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Computed Property

private extension HomeViewController {
    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(500)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(500)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
