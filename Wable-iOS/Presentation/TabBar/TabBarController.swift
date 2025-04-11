//
//  TabBarController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/9/25.
//


import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: Property

    private let shouldShowLoadingScreen: Bool
    
    // MARK: - UIComponent
    
    private lazy var homeViewController = HomeViewController(
        viewModel: HomeViewModel(
            fetchContentListUseCase: FetchContentListUseCase(repository: ContentRepositoryImpl()),
            createContentLikedUseCase: CreateContentLikedUseCase(repository: ContentLikedRepositoryImpl()),
            deleteContentLikedUseCase: DeleteContentLikedUseCase(repository: ContentLikedRepositoryImpl())
        ),
        cancelBag: CancelBag()
    ).then {
        $0.tabBarItem.title = "홈"
        $0.tabBarItem.image = .icHomeDefault
        $0.shouldShowLoadingScreen = self.shouldShowLoadingScreen
    }
    
    private let communityViewController = CommunityViewController(viewModel: CommunityViewModel(useCase: MockCommunityUseCaseImpl())).then {
        $0.tabBarItem.title = "커뮤니티"
        $0.tabBarItem.image = .icCommunity
    }
    
    private let overviewViewController = OverviewPageViewController().then {
        $0.tabBarItem.title = "소식"
        $0.tabBarItem.image = .icInfoPress
    }
    
    private let viewitViewController = ViewitViewController().then {
        $0.tabBarItem.title = "뷰잇"
        $0.tabBarItem.image = .icViewit
    }
    
    private let profileViewController = ProfileViewController().then {
        $0.tabBarItem.title = "마이"
        $0.tabBarItem.image = .icMyPress
    }
    
    // MARK: - LifeCycle

    init(shouldShowLoadingScreen: Bool = true) {
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
            animated: true
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
        tabBarAppearance.configureWithTransparentBackground()
        
        tabBar.do {
            $0.unselectedItemTintColor = .gray400
            $0.tintColor = .wableBlack
            $0.backgroundColor = .wableWhite
            $0.isTranslucent = false
            $0.standardAppearance = tabBarAppearance
            $0.scrollEdgeAppearance = tabBarAppearance
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            if navigationController.viewControllers.first is HomeViewController {
                if tabBarController.selectedIndex == 0 {
                    homeViewController.scrollToTop()
                }
            }
        }
    }
}
