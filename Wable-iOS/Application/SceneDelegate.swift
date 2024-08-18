//
//  SceneDelegate.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/5/24.
//

import UIKit

import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = SplashViewController()
        self.window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            if loadUserData()?.isSocialLogined == true && loadUserData()?.isJoinedApp == true && loadUserData()?.isOnboardingFinished == true {
                let navigationController = UINavigationController(rootViewController: WableTabBarController())
                self.window?.rootViewController = navigationController
            } else if loadUserData()?.isJoinedApp == false {
                let navigationController = UINavigationController(rootViewController: LoginViewController(viewModel: LoginViewModel()))
                self.window?.rootViewController = navigationController
            } else {
                let navigationController = UINavigationController(rootViewController: LoginViewController(viewModel: LoginViewModel()))
                self.window?.rootViewController = navigationController
            }
            self.window?.makeKeyAndVisible()
//            self.checkAndUpdateIfNeeded()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func checkAndUpdateIfNeeded() {
        AppStoreCheckManager().latestVersion { marketingVersion in
            DispatchQueue.main.async {
                guard let marketingVersion = marketingVersion else {
                    print("앱스토어 버전을 찾지 못했습니다.")
                    return
                }
                
                let currentProjectVersion = AppStoreCheckManager.appVersion ?? ""
                
                let splitMarketingVersion = marketingVersion.split(separator: ".").map { $0 }
                
                let splitCurrentProjectVersion = currentProjectVersion.split(separator: ".").map { $0 }
                
                if currentProjectVersion < marketingVersion {
                    self.showUpdateAlert(version: marketingVersion)
                } else {
                    print("현재 최신버전입니다.")
                }
            }
        }
    }
    
    func showUpdateAlert(version: String) {
        let alert = UIAlertController(
            title: StringLiterals.VersionUpdate.versionTitle,
            message: StringLiterals.VersionUpdate.versionMessage,
            preferredStyle: .alert
        )
        
        let updateAction = UIAlertAction(title: "지금 업데이트", style: .default) { _ in
            AppStoreCheckManager().openAppStore()
        }
        
        let cancelAction = UIAlertAction(title: "나중에", style: .destructive, handler: nil)
        
        [ cancelAction, updateAction ].forEach { alert.addAction($0) }
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
