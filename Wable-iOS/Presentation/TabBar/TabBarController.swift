//
//  TabBarController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/9/25.
//


import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: Property

    private var previousIndex: Int = 0
    private var shouldShowLoadingScreen: Bool
    
    // MARK: - UIComponent
    
    private lazy var homeViewController = HomeViewController(
        viewModel: HomeViewModel(
            fetchContentListUseCase: FetchContentListUseCase(repository: ContentRepositoryImpl()),
            createContentLikedUseCase: CreateContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
            deleteContentLikedUseCase: DeleteContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
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
    ).then {
        $0.tabBarItem.title = "홈"
        $0.tabBarItem.image = .icHomeDefault
        $0.shouldShowLoadingScreen = self.shouldShowLoadingScreen
    }
    
    private let communityViewController = CommunityViewController(
        viewModel: CommunityViewModel()
    ).then {
        $0.tabBarItem.title = "커뮤니티"
        $0.tabBarItem.image = .icCommunity
    }
    
    private let overviewViewController = OverviewPageViewController().then {
        $0.tabBarItem.title = "소식"
        $0.tabBarItem.image = .icInfoPress
    }
    
    private let viewitViewController = ViewitListViewController(
        viewModel: .init(
            useCase: ViewitUseCaseImpl(),
            likeUseCase: LikeViewitUseCaseImpl(),
            reportUseCase: ReportViewitUseCaseImpl(),
            checkUserRoleUseCase: CheckUserRoleUseCaseImpl(
                repository: UserSessionRepositoryImpl(
                    userDefaults: UserDefaultsStorage(
                        jsonEncoder: JSONEncoder(),
                        jsonDecoder: JSONDecoder()
                    )
                )
            ),
            userSessionUseCase: FetchUserInformationUseCase(
                repository: UserSessionRepositoryImpl(
                    userDefaults: UserDefaultsStorage(
                        jsonEncoder: JSONEncoder(),
                        jsonDecoder: JSONDecoder()
                    )
                )
            )
        )
    ).then {
        $0.tabBarItem.title = "뷰잇"
        $0.tabBarItem.image = .icViewit
    }
    
    private let profileViewController = MyProfileViewController(
        viewModel: .init(
            userinformationUseCase: FetchUserInformationUseCase(
                repository: UserSessionRepositoryImpl(
                    userDefaults: UserDefaultsStorage(jsonEncoder: .init(), jsonDecoder: .init())
                )
            ),
            fetchUserProfileUseCase: FetchUserProfileUseCaseImpl(),
            removeUserSessionUseCase: RemoveUserSessionUseCaseImpl(
                repository: UserSessionRepositoryImpl(
                    userDefaults: UserDefaultsStorage(
                        jsonEncoder: .init(), jsonDecoder: .init()
                    )
                )
            )
        )
    ).then {
        $0.tabBarItem.title = "마이"
        $0.tabBarItem.image = .icMyPress
    }
    
    // MARK: - LifeCycle

    init(shouldShowLoadingScreen: Bool = false) {
        self.shouldShowLoadingScreen = shouldShowLoadingScreen
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupDelegate()
    }
}

// MARK: - Private Extension

private extension TabBarController {
    
    // MARK: - Setup

    func setupView() {
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        let communityNavigationController = UINavigationController(rootViewController: communityViewController)
        let overviewNavigationController = UINavigationController(rootViewController: overviewViewController)
        let viewitNavigationController = UINavigationController(rootViewController: viewitViewController)
        let profileNavigationController = UINavigationController(rootViewController: profileViewController)
        
        configureTabBar()

        setViewControllers(
            [
                homeNavigationController,
                communityNavigationController,
                overviewNavigationController,
                viewitNavigationController,
                profileNavigationController
            ],
            animated: false
        )
    }
    
    func setupDelegate() {
        delegate = self
    }
}

// MARK: - Configure Extension

private extension TabBarController {
    func configureTabBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .wableWhite
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .gray400
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray400]
        
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .wableBlack
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.wableBlack]
        
        tabBar.do {
            $0.isTranslucent = false
            $0.standardAppearance = tabBarAppearance
            $0.scrollEdgeAppearance = tabBarAppearance
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let currentIndex = selectedIndex
        
        if let navigationController = viewController as? UINavigationController {
            if navigationController.viewControllers.first is HomeViewController {
                if tabBarController.selectedIndex == 0 {
                    homeViewController.scrollToTop()
                }
            }
        }
        
        switch currentIndex {
        case 0:
            AmplitudeManager.shared.trackEvent(tag: .clickHomeBotnavi)
        case 1:
            AmplitudeManager.shared.trackEvent(tag: .clickCommunityBotnavi)
        case 2:
            AmplitudeManager.shared.trackEvent(tag: .clickNewsBotnavi)
        case 3:
            AmplitudeManager.shared.trackEvent(tag: .clickViewitBotnavi)
        case 4:
            AmplitudeManager.shared.trackEvent(tag: .clickMyprofileBotnavi)
        default:
            break
        }
        
        if previousIndex == 4 && currentIndex == 0 {
            homeViewController.showLoadingScreen()
        }
        
        previousIndex = currentIndex
    }
}
