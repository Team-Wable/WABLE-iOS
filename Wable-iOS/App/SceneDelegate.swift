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
    
    /// Configures and presents the main window for the scene and initiates the auto-login process.
    /// 
    /// When the scene connects, this method creates a new window using the provided window scene, sets its root
    /// view controller to a splash screen, and makes the window key and visible. It also sets up a binding to listen
    /// for token expiration events and, after a 2-second delay, checks whether auto-login is enabled. Depending on the
    /// auto-login check result, it transitions to either the main screen or the login screen.
    /// 
    /// - Parameters:
    ///   - scene: The scene object that is connecting to the app.
    ///   - session: The session associated with the scene.
    ///   - connectionOptions: Options used to configure the scene’s connection.
    
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
    
    /// Handles incoming URL contexts for KakaoTalk authentication.
    ///
    /// Extracts the first URL from the provided set and, if it is recognized as a KakaoTalk login URL by AuthApi, delegates its handling to AuthController.
    
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
    /// Configures the login screen as the app's root view controller.
    /// 
    /// This method creates a `LoginViewController` with an associated `LoginViewModel` that is initialized
    /// using a `FetchUserAuthUseCase`. The use case leverages the login and user session repositories to manage user authentication.
    /// The configured view controller is then set as the window's root view controller.
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
    
    /// Configures the main application screen by setting the window's root view controller to a new instance of `TabBarController`.
    /// This effectively transitions the app to the main tab-based interface.
    func configureMainScreen() {
        self.window?.rootViewController = TabBarController()
    }
}

// MARK: - Private Extension

private extension SceneDelegate {
    
    /// Configures a subscription to token expiration events.
    /// 
    /// Listens to the `tokenExpiredSubject` from the shared OAuthEventManager on the main thread. When a token expiration event is received, it triggers `handleTokenExpired()` to handle the session update, storing the subscription in `cancelBag` for proper lifecycle management.

    func setupBinding() {
        OAuthEventManager.shared.tokenExpiredSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleTokenExpired()
            }
            .store(in: cancelBag)
    }
    
    
    /// Handles token expiration by clearing the active user session and prompting a re-login.
    /// 
    /// This method resets the active user ID, reconfigures the interface to display the login screen, 
    /// and shows a caution toast notifying the user that the session has expired.
    func handleTokenExpired() {
        userSessionRepository.updateActiveUserID(nil)
        configureLoginScreen()
        
        let toast = ToastView(status: .caution, message: "세션이 만료되었습니다. 다시 로그인해주세요.")
        toast.show()
    }
    
    /// Placeholder for forced update functionality.
    ///
    /// Future implementation should determine if a mandatory update is required and perform the necessary actions,
    /// such as notifying the user and redirecting them to the update screen.
    ///
    /// - Note: Forced update logic is not yet implemented.
    func updateVersionIfNeeded() {
        // TODO: 강제 업데이트 로직 구현 필요
    }
}
