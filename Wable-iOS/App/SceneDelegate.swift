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
    private let userSessionRepository: UserSessionRepository = UserSessionRepositoryImpl()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        userSessionRepository.checkAutoLogin()
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(_):
                    self.configureLoginScreen()
                }
            } receiveValue: { isAutoLoginEnabled in
                if isAutoLoginEnabled {
                    self.configureMainScreen()
                } else {
                    self.configureLoginScreen()
                }
            }
            .store(in: cancelBag)
    }
}

// MARK: - Extension
// TODO: 각각 VC로 화면 이동하는 로직 구현 필요

private extension SceneDelegate {
    func configureLoginScreen() {
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
    }
    
    func configureMainScreen() {
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
    }
}
