//
//  MyProfileViewController.swift
//  Wable-iOS
//
//  Created by 김진웅 on 5/14/25.
//

import UIKit
import SafariServices

import SnapKit
import Then

final class MyProfileViewController: UIViewController {
    
    enum Section: CaseIterable {
        case profile
        case post
    }
    
    enum Item: Hashable {
        case profile(UserProfile)
        case content(UserContent)
        case comment(UserComment)
    }
    
    // MARK: - Typealias
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias ViewModel = MyProfileViewModel
    
    // MARK: - Property

    private var dataSource: DataSource?
    
    private let viewModel: ViewModel
    private let didLoadRelay = PassthroughRelay<Void>()
    private let selectedIndexRelay = PassthroughRelay<Int>()
    private let logoutRelay = PassthroughRelay<Void>()
    private let cancelBag = CancelBag()
    private let rootView = MyProfileView()
    
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
        
        setupCollectionViewLayout()
        setupNavigationBar()
        setupDataSource()
        setupAction()
        setupBinding()
        
        didLoadRelay.send()
    }
}

private extension MyProfileViewController {
    
    // MARK: - Setup
    
    func setupCollectionViewLayout() {
        rootView.collectionView.collectionViewLayout = collectionViewLayout
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupDataSource() {
        let profileInfoCellRegistration = CellRegistration<ProfileInfoCell, UserProfile> { cell, indexPath, item in
            cell.configure(
                isMyProfile: true,
                profileImageURL: item.user.profileURL,
                level: "\(item.userLevel)",
                nickname: item.user.nickname,
                introduction: "\(item.user.fanTeam?.rawValue ?? "LCK")을(를) 응원하고 있어요.\n\(item.lckYears)부터 LCK를 보기 시작했어요.",
                ghostValue: item.ghostCount,
                editButtonTapHandler: { [weak self] in
                    self?.navigationController?.pushViewController(ProfileEditViewController(), animated: true)
                }
            )
        }
        
        let contentCellRegistration = CellRegistration<ContentCollectionViewCell, UserContent> {
            cell, indexPath, item in
            cell.configureCell(
                info: item.contentInfo,
                authorType: .mine,
                cellType: .list,
                contentImageViewTapHandler: nil,
                likeButtonTapHandler: {
                    WableLogger.log("좋아요 눌림", for: .debug)
                    
                    // TODO: 추후 기능 연결
                },
                settingButtonTapHandler: nil,
                profileImageViewTapHandler: nil,
                ghostButtonTapHandler: nil
            )
        }
        
        let commentCellRegistration = CellRegistration<CommentCollectionViewCell, UserComment> {
            cell, indexPath, item in
            
            cell.configureCell(
                info: item.comment,
                commentType: .ripple,
                authorType: .mine,
                likeButtonTapHandler: {
                    WableLogger.log("좋아요 눌림", for: .debug)
                    
                    // TODO: 추후 기능 연결
                },
                settingButtonTapHandler: nil,
                profileImageViewTapHandler: nil,
                ghostButtonTapHandler: nil,
                replyButtonTapHandler: nil
            )
        }
        
        let headerRegistration = SupplementaryRegistration<ProfileSegmentedHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.segmentDidChangeClosure = { [weak self] selectedIndex in
                self?.selectedIndexRelay.send(selectedIndex)
            }
        }
        
        dataSource = DataSource(collectionView: rootView.collectionView, cellProvider: {
            collectionView, indexPath, item in
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
        rootView.navigationView.menuButton.addTarget(self, action: #selector(menuButtonDidTap), for: .touchUpInside)
    }
    
    func setupBinding() {
        let input = ViewModel.Input(
            load: didLoadRelay.eraseToAnyPublisher(),
            selectedIndex: selectedIndexRelay.eraseToAnyPublisher(),
            logout: logoutRelay.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input, cancelBag: cancelBag)
        
        output.nickname
            .sink { [weak self] in self?.rootView.navigationView.setNavigationTitle(text: $0) }
            .store(in: cancelBag)
        
        output.item
            .sink { [weak self] in self?.applySnapshot(item: $0) }
            .store(in: cancelBag)
        
        output.errorMessage
            .sink { [weak self] message in
                let alert = UIAlertController(title: "에러 발생!", message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: cancelBag)
        
        output.shouldBeLogin
            .sink { _ in
                guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
                    return WableLogger.log("SceneDelegate 찾을 수 없음.", for: .debug)
                }
                
                sceneDelegate.window?.rootViewController = LoginViewController(
                    viewModel: .init(
                        updateFCMTokenUseCase: UpdateFCMTokenUseCase(
                            repository: ProfileRepositoryImpl()
                        ),
                        fetchUserAuthUseCase: FetchUserAuthUseCase(
                            loginRepository: LoginRepositoryImpl(),
                            userSessionRepository: UserSessionRepositoryImpl(
                                userDefaults: UserDefaultsStorage(jsonEncoder: .init(), jsonDecoder: .init())
                            )
                        ),
                        updateUserSessionUseCase: FetchUserInformationUseCase(
                            repository: UserSessionRepositoryImpl(
                                userDefaults: UserDefaultsStorage(jsonEncoder: .init(), jsonDecoder: .init())
                            )
                        )
                    )
                )
            }
            .store(in: cancelBag)
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
    
    // MARK: - Helper
    
    func applySnapshot(item: ProfileViewItem) {
        guard let profileInfo = item.profileInfo else {
            return WableLogger.log("프로필 없음.", for: .debug)
        }
        
        var snapshot = Snapshot()
        snapshot.appendSections([.profile, .post])
        snapshot.appendItems([.profile(profileInfo)], toSection: .profile)
        
        if viewModel.selectedSegment == .content {
            snapshot.appendItems(item.content.map { Item.content($0) }, toSection: .post)
        } else {
            snapshot.appendItems(item.comment.map { Item.comment($0) }, toSection: .post)
        }
        dataSource?.apply(snapshot)
    }

    func navigateToAccountInfo() {
        let viewModel = AccountInfoViewModel(useCase: FetchAccountInfoUseCaseImpl(repository: ProfileRepositoryImpl()))
        let viewController = AccountInfoViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func navigateToAlarmSetting() {
        let viewModel = AlarmSettingViewModel()
        let viewController = AlarmSettingViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentGoogleForm() {
        guard let url = URL(string: Constant.googleFormURLString) else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
    
    func presentLogoutActionSheet() {
        let actionSheet = WableSheetViewController(title: "로그아웃하시겠어요?")
        let cancelAction = WableSheetAction(title: "취소", style: .gray)
        let logoutAction = WableSheetAction(title: "로그아웃하기", style: .primary) { [weak self] in
            WableLogger.log("로그아웃 눌림.", for: .debug)
            
            self?.logoutRelay.send()
        }
        actionSheet.addActions(cancelAction, logoutAction)
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
    
    // MARK: - Constant

    enum Constant {
        static let googleFormURLString = "https://docs.google.com/forms/d/e/1FAIpQLSf3JlBkVRPaPFSreQHaEv-u5pqZWZzk7Y4Qll9lRP0htBZs-Q/viewform"
    }
}
