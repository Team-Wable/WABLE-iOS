//
//  TabBarController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/9/25.
//


import UIKit

final class TabBarController: UITabBarController {

    // MARK: Property

    var onLogout: (() -> Void)?

    private var previousIndex: Int = 0
    private var shouldShowLoadingScreen: Bool
    private var quizCoordinator: QuizCoordinator?
    private var viewitCoordinator: ViewitCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    
    @Injected private var userSessionRepository: UserSessionRepository
    
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
    
    private let overviewViewController = OverviewPageViewController(
        viewModel: OverviewPageViewModel(useCase: OverviewUseCaseImpl())
    ).then {
        $0.tabBarItem.title = "소식"
        $0.tabBarItem.image = .icInfoPress
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
        
        let viewitNavigationController = UINavigationController()
        viewitCoordinator = ViewitCoordinator(navigationController: viewitNavigationController)
        viewitCoordinator?.start()
        viewitNavigationController.tabBarItem = UITabBarItem(title: "뷰잇", image: .icViewit, selectedImage: nil)
        
        let quizNavigationController = UINavigationController()
        let hasCompleted = checkTodayQuizCompletion()
        quizCoordinator = QuizCoordinator(navigationController: quizNavigationController, hasCompleted: hasCompleted)
        quizCoordinator?.start()
        quizNavigationController.tabBarItem = UITabBarItem(title: "퀴즈", image: .icQuiz, selectedImage: nil)
        
        let profileNavigationController = UINavigationController()
        profileCoordinator = ProfileCoordinator(navigationController: profileNavigationController)
        profileCoordinator?.onLogout = { [weak self] in
            self?.onLogout?()
        }
        profileCoordinator?.start()
        profileNavigationController.tabBarItem = UITabBarItem(title: "마이", image: .icMyPress, selectedImage: nil)

        configureTabBar()

        setViewControllers(
            [
                homeNavigationController,
                communityNavigationController,
                quizNavigationController,
                overviewNavigationController,
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
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = viewControllers?.firstIndex(of: viewController), index == 2 {
            let hasCompleted = checkTodayQuizCompletion()

            if !hasCompleted {
                if let viewController = selectedViewController as? UINavigationController {
                    let quizViewController = QuizViewController(
                        type: .page(type: .quiz, title: "퀴즈"),
                        viewModel: .init()
                    )
                    viewController.pushViewController(quizViewController, animated: true)
                }
                return false
            }
        }
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let currentIndex = selectedIndex

        if let navigationController = viewController as? UINavigationController {
            if navigationController.viewControllers.first is HomeViewController {
                if tabBarController.selectedIndex == 0 {
                    homeViewController.scrollToTop()
                }
            }

            if currentIndex == 2 {
                let newQuizViewController = NextQuizInfoViewController(
                    type: .quiz,
                    viewModel: NextQuizInfoViewModel()
                )
                navigationController.setViewControllers([newQuizViewController], animated: false)
            }
        }

        switch currentIndex {
        case 0:
            AmplitudeManager.shared.trackEvent(tag: .clickHomeBotnavi)
        case 1:
            AmplitudeManager.shared.trackEvent(tag: .clickCommunityBotnavi)
        case 2:
//            AmplitudeManager.shared.trackEvent(tag: .clickQuizBotnavi)
            break
        case 3:
            AmplitudeManager.shared.trackEvent(tag: .clickNewsBotnavi)
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

// MARK: - Helper Methods

private extension TabBarController {
    func checkTodayQuizCompletion() -> Bool {
        guard let userSession = userSessionRepository.fetchActiveUserSession(),
              let quizCompletedAt = userSession.quizCompletedAt else {
            return false
        }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "KST") ?? TimeZone.current

        return calendar.isDateInToday(quizCompletedAt)
    }
}
