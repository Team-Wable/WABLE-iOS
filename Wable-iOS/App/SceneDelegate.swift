//
//  SceneDelegate.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//

import Combine
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Property

    private let cancelBag = CancelBag()
    private let userSessionRepository: UserSessionRepository = UserSessionRepositoryImpl(
        userDefaults: UserDefaultsStorage(
            userDefaults: UserDefaults.standard,
            jsonEncoder: JSONEncoder(),
            jsonDecoder: JSONDecoder()
        )
    )
    
    // MARK: - UIComponent

    var window: UIWindow?

    // MARK: - WillConnentTo
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = SplashViewController()
        self.window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.userSessionRepository.checkAutoLogin()
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        self.configureLoginScreen()
                    }
                } receiveValue: { isAutoLoginEnabled in
                    isAutoLoginEnabled ? self.configureMainScreen() : self.configureLoginScreen()
                    self.window?.makeKeyAndVisible()
                    self.updateVersionIfNeeded()
                }
                .store(in: self.cancelBag)
        }
    }
}

// MARK: - Configure Extension

private extension SceneDelegate {
    func configureLoginScreen() {
        self.window?.rootViewController = LCKYearViewController(type: .flow)
    }
    
    func configureMainScreen() {
        self.window?.rootViewController = TabBarController()
    }
}

// MARK: - Private Extension

private extension SceneDelegate {
    func updateVersionIfNeeded() {
        // TODO: 강제 업데이트 로직 구현 필요
    }
}
