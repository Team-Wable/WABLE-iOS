//
//  SceneDelegate.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/13/25.
//

import Combine
import UIKit

import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Property
    
    private let cancelBag = CancelBag()
    private let loginRepository = LoginRepositoryImpl()
    private let userSessionRepository = UserSessionRepositoryImpl(
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
        
        AuthEventManager.shared.tokenExpiredSubject
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, _ in
                if let sessionID = owner.userSessionRepository.fetchActiveUserSession()?.id {
                    WableLogger.log("토큰 만료로 인한 활성 세션 삭제 후 로그인 화면 전환", for: .debug)
                    owner.userSessionRepository.removeUserSession(forUserID: sessionID)
                }
                
                owner.configureLoginScreen()
            }
            .store(in: cancelBag)
        
#if DEBUG
        if let sessionID = userSessionRepository.fetchActiveUserSession()?.id {
            WableLogger.log("로그인 기능 구현을 위한 활성 세션 삭제", for: .debug)
            userSessionRepository.removeUserSession(forUserID: sessionID)
        }
#endif
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.userSessionRepository.checkAutoLogin()
                .withUnretained(self)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        WableLogger.log("로그인 실패: \(error)", for: .error)
                    }
                } receiveValue: { owner, isAutoLoginEnabled in
                    isAutoLoginEnabled ? owner.configureMainScreen() : owner.configureLoginScreen()
                    owner.window?.makeKeyAndVisible()
                    owner.updateVersionIfNeeded()
                }
                .store(in: self.cancelBag)
        }
    }
    
    // MARK: - Kakao URLContexts
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}

// MARK: - Configure Extension

private extension SceneDelegate {
    func configureLoginScreen() {
        self.window?.rootViewController = LoginViewController(
            viewModel: LoginViewModel(
                useCase: FetchUserAuthUseCase(
                    loginRepository: loginRepository,
                    userSessionRepository: userSessionRepository
                )
            )
        )
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
