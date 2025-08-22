//
//  MyProfileViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import Combine
import UIKit
import SafariServices

import SnapKit
import Then

final class MyProfileViewController: UIViewController {
    
    // MARK: - Section & Item

    enum Section: Int, CaseIterable {
        case profile
        case post
    }
    
    enum Item: Hashable {
        case profile(UserProfile)
        case content(Content)
        case comment(CommentTemp)
        case empty(ProfileEmptyCellItem)
    }
    
    // MARK: - Typealias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - UIComponent
    
    private let navigationView = NavigationView(type: .page(type: .profile, title: "이름"))
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: collectionViewLayout
    ).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .gray600
    }

    // MARK: - Property

    private var dataSource: DataSource?
    
    private let viewModel: MyProfileViewModel
    private let willDisplaySubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer

    init(viewModel: MyProfileViewModel) {
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
        setupNavigationBar()
        setupDataSource()
        setupAction()
        setupBinding()
        setupDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewDidRefresh()
    }
}

// MARK: - UICollectionViewDelegate

extension MyProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section), section == .post else { return }
        
        if collectionView.cellForItem(at: indexPath) is MyProfileEmptyCell {
            return
        }
        
        let contentID = viewModel.didSelect(index: indexPath.item)
        
        let viewController = HomeDetailViewController(
            viewModel: HomeDetailViewModel(
                contentID: contentID,
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
        
        navigationController?.pushViewController(viewController, animated: true)
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
        
        if indexPath.item >= itemCount - 2 {
            viewModel.willDisplayLast()
        }
    }
}

private extension MyProfileViewController {
    
    // MARK: - Setup
    
    func setupView() {
        view.backgroundColor = .wableWhite
        
        navigationView.setNavigationTitle(text: viewModel.nickname ?? "알 수 없음")
        
        let underlineView = UIView(backgroundColor: .gray200)
        
        view.addSubviews(navigationView, collectionView, loadingIndicator, underlineView)
        
        navigationView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
            make.adjustedHeightEqualTo(56)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
        
        underlineView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(safeArea)
            make.height.equalTo(1)
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupDataSource() {
        let profileInfoCellRegistration = CellRegistration<ProfileInfoCell, UserProfile> { cell, indexPath, item in
            let fanTeamName = item.user.fanTeam?.rawValue ?? "LCK"
            cell.configure(
                isMyProfile: true,
                profileImageURL: item.user.profileURL,
                level: "\(item.userLevel)",
                nickname: item.user.nickname,
                introduction: "\(fanTeamName)을(를) 응원하고 있어요.\n\(item.lckYears)부터 LCK를 보기 시작했어요.",
                ghostValue: item.ghostCount,
                editButtonTapHandler: { [weak self] in
                    self?.navigationController?.pushViewController(ProfileEditViewController(), animated: true)
                }
            )
        }
        
        let contentCellRegistration = CellRegistration<ContentCollectionViewCell, Content> {
            cell, indexPath, item in
            cell.configureCell(
                info: item,
                authorType: .mine,
                cellType: .list,
                contentImageViewTapHandler: { [weak self] in
                    guard let image = cell.contentImageView.image else { return }
                    
                    let photoDetailViewController = PhotoDetailViewController(image: image)
                    self?.navigationController?.pushViewController(photoDetailViewController, animated: true)
                },
                likeButtonTapHandler: { [weak self] in self?.viewModel.toggleLikeContent(for: item.id) },
                settingButtonTapHandler: { [weak self] in
                    let bottomSheet = WableBottomSheetController()
                    bottomSheet.addAction(
                        .init(
                            title: "삭제하기",
                            handler: { [weak self] in self?.presentDeleteContentActionSheet(for: item.id) }
                        )
                    )
                    self?.present(bottomSheet, animated: true)
                },
                profileImageViewTapHandler: nil,
                ghostButtonTapHandler: nil
            )
        }
        
        let commentCellRegistration = CellRegistration<CommentCollectionViewCell, CommentTemp> {
            cell, indexPath, item in
            
            cell.configureCell(
                info: item,
                commentType: .ripple,
                authorType: .mine,
                likeButtonTapHandler: { [weak self] in self?.viewModel.toggleLikeComment(for: item.id) },
                settingButtonTapHandler: { [weak self] in
                    let bottomSheet = WableBottomSheetController()
                    bottomSheet.addAction(
                        .init(
                            title: "삭제하기",
                            handler: { [weak self] in self?.presentDeleteCommentActionSheet(for: item.id) }
                        )
                    )
                    self?.present(bottomSheet, animated: true)
                },
                profileImageViewTapHandler: nil,
                ghostButtonTapHandler: nil,
                replyButtonTapHandler: nil
            )
        }
        
        let headerRegistration = SupplementaryRegistration<ProfileSegmentedHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.onSegmentIndexChanged = { [weak self] in self?.viewModel.selectedIndexDidChange($0) }
        }
        
        let emptyCellRegistration = CellRegistration<MyProfileEmptyCell, ProfileEmptyCellItem> {
            [weak self] cell, indexPath, item in
            cell.configure(currentSegment: item.segment, nickname: item.nickname)
            
            cell.writeButtonDidTapClosure = { [weak self] in
                let viewController = WritePostViewController(
                    viewModel: WritePostViewModel(
                        createContentUseCase: CreateContentUseCase(
                            repository: ContentRepositoryImpl()
                        )
                    )
                )
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch item {
            case .profile(let profileInfo):
                return collectionView.dequeueConfiguredReusableCell(
                    using: profileInfoCellRegistration,
                    for: indexPath,
                    item: profileInfo
                )
            case .content(let content):
                return collectionView.dequeueConfiguredReusableCell(
                    using: contentCellRegistration,
                    for: indexPath,
                    item: content
                )
            case .comment(let comment):
                return collectionView.dequeueConfiguredReusableCell(
                    using: commentCellRegistration,
                    for: indexPath,
                    item: comment
                )
            case .empty(let segment):
                return collectionView.dequeueConfiguredReusableCell(
                    using: emptyCellRegistration,
                    for: indexPath,
                    item: segment
                )
            }
        })
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = Section.allCases[indexPath.section]
            switch section {
            case .post:
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            default:
                return nil
            }
        }
    }

    func setupAction() {
        navigationView.menuButton.addTarget(self, action: #selector(menuButtonDidTap), for: .touchUpInside)
        
        collectionView.refreshControl?.addTarget(self, action: #selector(collectionViewDidRefresh), for: .valueChanged)
        
        willDisplaySubject
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.viewModel.willDisplayLast() }
            .store(in: cancelBag)
    }
    
    func setupBinding() {
        viewModel.$nickname
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.navigationView.setNavigationTitle(text: $0 ?? "알 수 없는 유저") }
            .store(in: cancelBag)
        
        viewModel.$item
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.applySnapshot(item: $0) }
            .store(in: cancelBag)
        
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .filter { $0 }
            .sink { [weak self] _ in self?.collectionView.refreshControl?.endRefreshing() }
            .store(in: cancelBag)
        
        viewModel.$isLoadingMore
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                let loadingIndicator = self?.loadingIndicator
                $0 ? loadingIndicator?.startAnimating() : loadingIndicator?.stopAnimating()
            }
            .store(in: cancelBag)
        
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                let alert = UIAlertController(title: "에러 발생!", message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: cancelBag)
    }
    
    func setupDelegate() {
        collectionView.delegate = self
    }
    
    // MARK: - Action

    @objc func menuButtonDidTap() {
        let bottomSheet = WableBottomSheetController()
        let accountInfoAction = WableBottomSheetAction(title: "계정 정보") { [weak self] in self?.navigateToAccountInfo() }
        let alarmSettingAction = WableBottomSheetAction(title: "알림 설정") { [weak self] in self?.navigateToAlarmSetting() }
        let feedbackAction = WableBottomSheetAction(title: "피드백 남기기") { [weak self] in self?.presentGoogleForm() }
        let helpAction = WableBottomSheetAction(title: "고객센터") { [weak self] in self?.presentGoogleForm() }
        let logoutAction = WableBottomSheetAction(title: "로그아웃") { [weak self] in self?.presentLogoutActionSheet() }
        bottomSheet.addActions(
            accountInfoAction,
            alarmSettingAction,
            feedbackAction,
            helpAction,
            logoutAction
        )
        present(bottomSheet, animated: true)
    }
    
    @objc func collectionViewDidRefresh() {
        viewModel.viewDidRefresh()
    }
    
    // MARK: - Helper
    
    func applySnapshot(item: ProfileViewItem) {
        guard let profileInfo = item.profileInfo else {
            return WableLogger.log("프로필 없음.", for: .debug)
        }
        
        var snapshot = Snapshot()
        snapshot.appendSections([.profile, .post])
        snapshot.appendItems([.profile(profileInfo)], toSection: .profile)
        
        if item.currentSegment == .content {
            if item.contentList.isEmpty {
                snapshot.appendItems(
                    [.empty(ProfileEmptyCellItem(segment: item.currentSegment, nickname: viewModel.nickname))],
                    toSection: .post
                )
            } else {
                snapshot.appendItems(item.contentList.map { Item.content($0) }, toSection: .post)
            }
        } else {
            if item.commentList.isEmpty {
                snapshot.appendItems(
                    [.empty(ProfileEmptyCellItem(segment: item.currentSegment, nickname: viewModel.nickname))],
                    toSection: .post
                )
            } else {
                snapshot.appendItems(item.commentList.map { Item.comment($0) }, toSection: .post)
            }
        }
        
        dataSource?.apply(snapshot)
    }

    func navigateToAccountInfo() {
        let viewModel = AccountInfoViewModel(useCase: FetchAccountInfoUseCaseImpl())
        let viewController = AccountInfoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func navigateToAlarmSetting() {
        let viewModel = AlarmSettingViewModel()
        let viewController = AlarmSettingViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentGoogleForm() {
        guard let url = URL(string: StringLiterals.URL.feedbackForm) else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
    
    func presentLogoutActionSheet() {
        let actionSheet = WableSheetViewController(title: StringLiterals.ProfileDelete.logoutSheetTitle)
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let logoutAction = WableSheetAction(title: "로그아웃하기", style: .primary) { [weak self] in
            AmplitudeManager.shared.trackEvent(tag: .clickCompleteLogout)
            
            self?.viewModel.logoutDidTap()
            self?.presentLoginView()
        }
        actionSheet.addActions(cancelAction, logoutAction)
        present(actionSheet, animated: true)
    }
    
    func presentLoginView() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window
        else {
            return WableLogger.log("SceneDelegate 찾을 수 없음.", for: .debug)
        }
        
        let loginViewController = LoginViewController(viewModel: LoginViewModel())
        
        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionCrossDissolve],
            animations: { window.rootViewController = loginViewController },
            completion: nil
        )
    }
    
    func presentDeleteContentActionSheet(for contentID: Int) {
        let actionSheet = WableSheetViewController(title: StringLiterals.Delete.contentSheetTitle, message: StringLiterals.Delete.contentSheetMessage)
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let confirmAction = WableSheetAction(title: "삭제하기", style: .primary) { [weak self] in
            self?.viewModel.deleteContent(for: contentID)
        }
        actionSheet.addActions(cancelAction, confirmAction)
        present(actionSheet, animated: true)
    }
    
    func presentDeleteCommentActionSheet(for commentID: Int) {
        let actionSheet = WableSheetViewController(title: StringLiterals.Delete.commentSheetTitle, message: StringLiterals.Delete.commentSheetMessage)
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let confirmAction = WableSheetAction(title: "삭제하기", style: .primary) { [weak self] in
            self?.viewModel.deleteComment(for: commentID)
        }
        actionSheet.addActions(cancelAction, confirmAction)
        present(actionSheet, animated: true)
    }
    
    // MARK: - Computed Property

    var collectionViewLayout: UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let sectionKind = Section.allCases[sectionIndex]
            
            switch sectionKind {
            case .profile:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(336)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(336)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
                
            case .post:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(48)
                )
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                sectionHeader.pinToVisibleBounds = true
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
            }
        }
    }
}
