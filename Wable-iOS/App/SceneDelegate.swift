//
//  SceneDelegate.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//

import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let cancelBag = CancelBag()
    private let userSessionRepository: UserSessionRepository = UserSessionRepositoryImpl(
        userDefaults: UserDefaultsStorage(
            userDefaults: UserDefaults.standard,
            jsonEncoder: JSONEncoder(),
            jsonDecoder: JSONDecoder()
        )
    )

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        userSessionRepository.checkAutoLogin()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    self.configureLoginScreen()
                }
            } receiveValue: { isAutoLoginEnabled in
                isAutoLoginEnabled ? self.configureMainScreen() : self.configureLoginScreen()
            }
            .store(in: cancelBag)
    }
}

// MARK: - Extension

private extension SceneDelegate {
    // TODO: 로그인 화면으로 이동하는 로직 구현 필요
    func configureLoginScreen() {
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
    }
    
    func configureMainScreen() {
        let condition = userSessionRepository.fetchActiveUserSession()?.notificationBadgeCount ?? 0 > 0
        
        self.window?.rootViewController = TabBarController(
            navigationView: NavigationView(
                type: .home(hasNewNotification: condition)
            )
        )
        self.window?.makeKeyAndVisible()
    }
}
