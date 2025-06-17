//
//  OtherProfileViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/20/25.
//

import Combine
import UIKit

import SnapKit
import Then

final class OtherProfileViewController: UIViewController {
    
    // MARK: - Section & Item
    
    enum Section: Int, CaseIterable {
        case profile
        case post
    }
    
    enum Item: Hashable {
        case profile(UserProfile)
        case content(UserContent)
        case comment(UserComment)
        case empty(ProfileEmptyCellItem)
    }
    
    // MARK: - Typealias

    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    // MARK: - UIComponent

    private let navigationView = NavigationView(type: .page(type: .detail, title: "닉네임"))
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout).then {
        $0.refreshControl = UIRefreshControl()
        $0.alwaysBounceVertical = true
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .gray600
    }
    
    // MARK: - Property
    
    private var dataSource: DataSource?
    
    private let viewModel: OtherProfileViewModel
    private let willLastDisplaySubject = PassthroughSubject<Void, Never>()
    private let cancelBag = CancelBag()
    
    // MARK: - Initializer

    init(viewModel: OtherProfileViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAction()
        setupNavigationBar()
        setupDataSource()
        setupDelegate()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.viewDidRefresh()
    }
}

// MARK: - UICollectionViewDelegate

extension OtherProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section), section == .post else { return }
        
        if collectionView.cellForItem(at: indexPath) is OtherProfileEmptyCell {
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
            willLastDisplaySubject.send()
        }
    }
}

private extension OtherProfileViewController {
    
    // MARK: - Setup
    
    func setupView() {
        view.backgroundColor = .wableWhite
        
        view.addSubviews(navigationView, collectionView, loadingIndicator)
        
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
    }
    
    func setupAction() {
        navigationView.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        
        collectionView.refreshControl?.addTarget(self, action: #selector(collectionViewDidRefresh), for: .valueChanged)
        
        willLastDisplaySubject
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.viewModel.willDisplayLast() }
            .store(in: cancelBag)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupDataSource() {
        let profileInfoCellRegistration = CellRegistration<ProfileInfoCell, UserProfile> { cell, indexPath, item in
            let fanTeamName = item.user.fanTeam?.rawValue ?? "LCK"
            cell.configure(
                isMyProfile: false,
                profileImageURL: item.user.profileURL,
                level: "\(item.userLevel)",
                nickname: item.user.nickname,
                introduction: "\(fanTeamName)을(를) 응원하고 있어요.\n\(item.lckYears)부터 LCK를 보기 시작했어요.",
                ghostValue: item.ghostCount,
                editButtonTapHandler: nil
            )
        }
        
        let contentCellRegistration = CellRegistration<ContentCollectionViewCell, UserContent> {
            cell, indexPath, item in
            cell.configureCell(
                info: item.contentInfo,
                authorType: .others,
                cellType: .list,
                contentImageViewTapHandler: { [weak self] in
                    guard let image = cell.contentImageView.image else { return }
                    
                    let photoDetailViewController = PhotoDetailViewController(image: image)
                    self?.navigationController?.pushViewController(photoDetailViewController, animated: true)
                },
                likeButtonTapHandler: { [weak self] in self?.viewModel.toggleLikeContent(for: item.id) },
                settingButtonTapHandler: { [weak self] in
                    guard let userRole = self?.viewModel.checkUserRole(),
                          userRole != .owner
                    else {
                        return
                    }
                    
                    let bottomSheet = WableBottomSheetController()
                    let report = WableBottomSheetAction(title: "신고하기") { [weak self] in
                        self?.presentReportSheet(contentID: item.id)
                    }
                    bottomSheet.addAction(report)
                    
                    if userRole == .admin {
                        let ban = WableBottomSheetAction(title: "밴하기") { [weak self] in
                            self?.presentBanSheet(contentID: item.id)
                        }
                        bottomSheet.addAction(ban)
                    }
                    self?.present(bottomSheet, animated: true)
                },
                profileImageViewTapHandler: nil,
                ghostButtonTapHandler: { [weak self] in self?.presentGhostSheet(contentID: item.id) }
            )
        }
        
        let commentCellRegistration = CellRegistration<CommentCollectionViewCell, UserComment> {
            cell, indexPath, item in
            
            cell.configureCell(
                info: item.comment,
                commentType: .ripple,
                authorType: .others,
                likeButtonTapHandler: { [weak self] in self?.viewModel.toggleLikeComment(for: item.comment.id) },
                settingButtonTapHandler: { [weak self] in
                    guard let userRole = self?.viewModel.checkUserRole(),
                          userRole != .owner
                    else {
                        return
                    }
                    
                    let bottomSheet = WableBottomSheetController()
                    let report = WableBottomSheetAction(title: "신고하기") { [weak self] in
                        self?.presentReportSheet(commentID: item.comment.id)
                    }
                    bottomSheet.addAction(report)
                    
                    if userRole == .admin {
                        let ban = WableBottomSheetAction(title: "밴하기") { [weak self] in
                            self?.presentBanSheet(commentID: item.comment.id)
                        }
                        bottomSheet.addAction(ban)
                    }
                    self?.present(bottomSheet, animated: true)
                },
                profileImageViewTapHandler: nil,
                ghostButtonTapHandler: { [weak self] in self?.presentGhostSheet(commentID: item.comment.id) },
                replyButtonTapHandler: nil
            )
        }
        
        let headerRegistration = SupplementaryRegistration<ProfileSegmentedHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.onSegmentIndexChanged = { [weak self] in self?.viewModel.selectedIndexDidChange($0) }
        }
        
        let emptyCellRegistration = CellRegistration<OtherProfileEmptyCell, ProfileEmptyCellItem> {
            cell, indexPath, item in
            cell.configure(currentSegment: item.segment, nickname: item.nickname)
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
    
    func setupDelegate() {
        collectionView.delegate = self
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
        
        viewModel.$isReportCompleted
            .receive(on: RunLoop.main)
            .filter { $0 }
            .sink { _ in ToastView(status: .complete, message: StringLiterals.Ghost.completeToast).show() }
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
    
    // MARK: - Helper
    
    func applySnapshot(item: ProfileViewItem) {
        guard let profileInfo = item.profileInfo else {
            return WableLogger.log("프로필 정보를 확인할 수 없음.", for: .debug)
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
    
    func presentReportSheet(contentID: Int) {
        let actionSheet = WableSheetViewController(
            title: StringLiterals.Report.sheetTitle,
            message: StringLiterals.Report.sheetMessage
        )
        
        let cancel = WableSheetAction(title: Constant.Cancel.title, style: .gray)
        let confirm = WableSheetAction(title: Constant.Report.title, style: .primary) { [weak self] in
            self?.viewModel.reportContent(for: contentID)
        }
        actionSheet.addActions(cancel, confirm)
        present(actionSheet, animated: true)
    }
    
    func presentReportSheet(commentID: Int) {
        let actionSheet = WableSheetViewController(
            title: StringLiterals.Report.sheetTitle,
            message: StringLiterals.Report.sheetMessage
        )
        
        let cancel = WableSheetAction(title: Constant.Cancel.title, style: .gray)
        let confirm = WableSheetAction(title: Constant.Report.title, style: .primary) { [weak self] in
            self?.viewModel.reportComment(for: commentID)
        }
        actionSheet.addActions(cancel, confirm)
        present(actionSheet, animated: true)
    }
    
    func presentBanSheet(contentID: Int) {
        let actionSheet = WableSheetViewController(
            title: Constant.Ban.title,
            message: StringLiterals.Ban.sheetMessage
        )
        
        let cancel = WableSheetAction(title: Constant.Cancel.title, style: .gray)
        let confirm = WableSheetAction(title: Constant.Ban.title, style: .primary) { [weak self] in
            self?.viewModel.banContent(for: contentID)
        }
        actionSheet.addActions(cancel, confirm)
        present(actionSheet, animated: true)
    }
    
    func presentBanSheet(commentID: Int) {
        let actionSheet = WableSheetViewController(
            title: Constant.Ban.title,
            message: StringLiterals.Ban.sheetMessage
        )
        
        let cancel = WableSheetAction(title: Constant.Cancel.title, style: .gray)
        let confirm = WableSheetAction(title: Constant.Ban.title, style: .primary) { [weak self] in
            self?.viewModel.banComment(for: commentID)
        }
        actionSheet.addActions(cancel, confirm)
        present(actionSheet, animated: true)
    }
    
    func presentGhostSheet(contentID: Int) {
        let actionSheet = WableSheetViewController(title: StringLiterals.Ghost.sheetTitle)
        let cancel = WableSheetAction(title: Constant.Ghost.grayTitle, style: .gray)
        let confirm = WableSheetAction(title: Constant.Ghost.primaryTitle, style: .primary) { [weak self] in
            self?.viewModel.ghostContent(for: contentID)
        }
        actionSheet.addActions(cancel, confirm)
        present(actionSheet, animated: true)
    }
    
    func presentGhostSheet(commentID: Int) {
        let actionSheet = WableSheetViewController(title: StringLiterals.Ghost.sheetTitle)
        let cancel = WableSheetAction(title: Constant.Ghost.grayTitle, style: .gray)
        let confirm = WableSheetAction(title: Constant.Ghost.primaryTitle, style: .primary) { [weak self] in
            self?.viewModel.ghostComment(for: commentID)
        }
        actionSheet.addActions(cancel, confirm)
        present(actionSheet, animated: true)
    }
    
    // MARK: - Action
    
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func collectionViewDidRefresh() {
        viewModel.viewDidRefresh()
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
    
    enum Constant {
        enum Report {
            static let title = "신고하기"
        }
        
        enum Ban {
            static let title = "밴하기"
        }
        
        enum Ghost {
            static let grayTitle = "고민할게요"
            static let primaryTitle = "네 맞아요"
        }
        
        enum Cancel {
            static let title = "취소"
        }
    }
}
