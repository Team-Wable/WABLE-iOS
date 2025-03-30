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
    private let tokenStorage = TokenStorage(keyChainStorage: KeychainStorage())
    private let tokenProvider = OAuthTokenProvider()
    
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
        
        setupBinding()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.userSessionRepository.checkAutoLogin()
                .withUnretained(self)
                .sink { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        WableLogger.log("자동 로그인 여부 체크 실패: \(error)", for: .error)
                        self?.configureLoginScreen()
                    }
                } receiveValue: { owner, isAutologinEnabled in
                    WableLogger.log("자동 로그인 여부 체크 성공: \(isAutologinEnabled)", for: .debug)
                    isAutologinEnabled ? owner.configureMainScreen() : owner.configureLoginScreen()
                }
                .store(in: self.cancelBag)
        }
    }
    
    // MARK: - Kakao URLContexts
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              AuthApi.isKakaoTalkLoginUrl(url)
        else {
            return
        }
        
        _ = AuthController.handleOpenUrl(url: url)
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
    
    // MARK: - Setup

    func setupBinding() {
        OAuthEventManager.shared.tokenExpiredSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleTokenExpired()
            }
            .store(in: cancelBag)
    }
    
    
    func handleTokenExpired() {
        userSessionRepository.updateActiveUserID(nil)
        configureLoginScreen()
        
        let toast = ToastView(status: .caution, message: "세션이 만료되었습니다. 다시 로그인해주세요.")
        toast.show()
    }
    
    func updateVersionIfNeeded() {
        // TODO: 강제 업데이트 로직 구현 필요
    }
}
