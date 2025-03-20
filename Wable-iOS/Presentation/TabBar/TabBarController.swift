//
//  TabBarController.swift
//  Wable-iOS
//
//  Created by YOUJIM on 3/9/25.
//


import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - UIComponent
    
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

    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
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
