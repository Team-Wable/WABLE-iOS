//
//  WableTabBarController.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/8/24.
//

import UIKit

final class WableTabBarController: UITabBarController {
    
    private var previousTabIndex: Int = 0

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setTabBarController()
        self.setInitialFont()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        self.delegate = self
    }
    
    // MARK: - TabBar Height
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let safeAreaHeight = view.safeAreaInsets.bottom
        let tabBarHeight: CGFloat = 52.0.adjusted
        tabBar.frame.size.height = tabBarHeight + safeAreaHeight
        tabBar.frame.origin.y = view.frame.height - tabBarHeight - safeAreaHeight
    }
    
    // MARK: - Set UI
    
    private func setUI() {
        self.tabBar.backgroundColor = .wableWhite // 탭바 배경색 설정
        self.tabBar.barTintColor = .wableWhite
        self.tabBar.isTranslucent = false // 배경이 투명하지 않도록 설정
    }
    
    // MARK: - Methods
    
    private func setTabBarController() {
        var tabNavigationControllers = [UINavigationController]()
        
        for item in WableTabBarItem.allCases {
            let tabNavController = createTabNavigationController(
                title: item.title,
                image: item.icon,
                selectedImage: item.selectedIcon,
                viewController: item.targetViewController
            )
            tabNavigationControllers.append(tabNavController)
        }
        
        setViewControllers(tabNavigationControllers, animated: false)
    }
    
    private func createTabNavigationController(title: String, image: UIImage, selectedImage: UIImage, viewController: UIViewController?) -> UINavigationController {
        let tabNavigationController = UINavigationController()

        let tabBarItem = UITabBarItem(
            title: title,
            image: image.withRenderingMode(.alwaysOriginal),
            selectedImage: selectedImage.withRenderingMode(.alwaysOriginal)
        )
        
        applyFontColorAttributes(to: UITabBarItem.appearance(), isSelected: false)
        
        tabNavigationController.tabBarItem = tabBarItem
        
        if let viewController = viewController {
            tabNavigationController.viewControllers = [viewController]
        }
        
        return tabNavigationController
    }
    
    private func setInitialFont() {
        // 디폴트로 선택된 탭의 폰트 설정
        if let selectedItem = self.tabBar.items?[self.selectedIndex] {
            self.applyFontColorAttributes(to: selectedItem, isSelected: true)
        }
    }
    
    func applyFontColorAttributes(to tabBarItem: UITabBarItem, isSelected: Bool) {
        let attributes: [NSAttributedString.Key: Any]
        
        if isSelected {
            attributes = [
                .font: UIFont.caption4,
                .foregroundColor: UIColor.wableBlack
            ] // title이 선택되었을 때 폰트, 색상 설정
        } else {
            attributes = [
                .font: UIFont.caption4,
                .foregroundColor: UIColor.gray500
            ] // title이 선택되지 않았을 때 폰트, 색상 설정
        }
        tabBarItem.setTitleTextAttributes(attributes, for: .normal)
    }
}

extension WableTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if let selectedViewController = tabBarController.selectedViewController {
            applyFontColorAttributes(to: selectedViewController.tabBarItem, isSelected: true)
        }
        let myViewController = tabBarController.viewControllers ?? [UIViewController()]
        for (index, controller) in myViewController.enumerated() {
            if let tabBarItem = controller.tabBarItem {
                if index != tabBarController.selectedIndex {
                    applyFontColorAttributes(to: tabBarItem, isSelected: false)
                }
            }
        }
        
        switch tabBarController.selectedIndex {
        case 0:

            if let navController = viewController as? UINavigationController,
               let homeVC = navController.viewControllers.first as? MigratedHomeViewController {
                homeVC.scrollToTop()
                if previousTabIndex == 3 {
                    homeVC.showLoadView()
                }
            }
            
            AmplitudeManager.shared.trackEvent(tag: "click_home_botnavi")
        case 1:
            AmplitudeManager.shared.trackEvent(tag: "click_news_botnavi")
        case 2:
            AmplitudeManager.shared.trackEvent(tag: "click_noti_botnavi")
        case 3:
            AmplitudeManager.shared.trackEvent(tag: "click_myprofile_botnavi")
        default:
            break
        }
        previousTabIndex = tabBarController.selectedIndex
    }
}
