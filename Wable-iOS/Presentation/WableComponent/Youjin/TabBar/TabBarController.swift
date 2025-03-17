//
//  TabBarController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/9/25.
//


import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - UIComponent

    private let navigationView: NavigationView
    
    private let homeViewController = HomeViewController().then {
        $0.tabBarItem.title = "홈"
        $0.tabBarItem.image = .icHomeDefault
    }
    
    private let communityViewController = CommunityViewController().then {
        $0.tabBarItem.title = "커뮤니티"
        $0.tabBarItem.image = .icCommunity
    }
    
    private let overviewViewController = OverviewViewController().then {
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

    init(navigationView: NavigationView) {
        self.navigationView = navigationView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupAction()
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
        configureNavigationView()

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
    
    func setupAction() {
        navigationView.do {
            $0.notificationButton.addTarget(self, action: #selector(notificationButtonDidTap), for: .touchUpInside)
            $0.backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
            $0.dismissButton.addTarget(self, action: #selector(dismissButtonDidTap), for: .touchUpInside)
            $0.menuButton.addTarget(self, action: #selector(menuButtonDidTap), for: .touchUpInside)
        }
    }
    
    // MARK: - @objc method

    @objc func notificationButtonDidTap() {
        // TODO: 알림 화면으로 이동하는 로직 구현 필요
    }
    
    @objc func backButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc func menuButtonDidTap() {
        // TODO: 프로필 바텀시트 올라오는 로직 구현 필요
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
    
    func configureNavigationView() {
        let condition = navigationView.type.isHub
        
        view.addSubview(navigationView)
        
        navigationView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(condition ? view : view.safeAreaLayoutGuide)
            $0.adjustedHeightEqualTo(condition ? 104 : 60)
        }
    }
}
