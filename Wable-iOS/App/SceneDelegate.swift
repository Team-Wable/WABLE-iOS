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
    private let tokenProvider = OAuthTokenProvider()
    private let checkAppUpdateRequirementUseCase = CheckAppUpdateRequirementUseCaseImpl()
    
    private var loginCoordinator: LoginCoordinator?
    private var diContainer: AppDIContainer { AppDIContainer.shared }
    
    private lazy var tokenStorage: TokenStorage = diContainer.resolve(for: TokenStorage.self, env: .production)
    private lazy var loginRepository: LoginRepository = diContainer.resolve(for: LoginRepository.self, env: .production)
    private lazy var profileRepository: ProfileRepository = diContainer.resolve(for: ProfileRepository.self, env: .production)
    private lazy var userSessionRepository: UserSessionRepository = diContainer.resolve(for: UserSessionRepository.self, env: .production)
    
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
        checkUpdate()
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
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator?.start()
        self.window?.rootViewController = navigationController
    }
    
    func configureMainScreen() {
        self.window?.rootViewController = TabBarController(shouldShowLoadingScreen: true)
    }
    
    func proceedToAppLaunch() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) { [weak self] in
            guard let self = self else { return }
            let session = userSessionRepository.fetchActiveUserSession()
            let shouldAutoLogin = session?.isAutoLoginEnabled == true && session?.nickname != ""
            
            if shouldAutoLogin {
                updateFCMToken()
                configureMainScreen()
            } else {
                configureLoginScreen()
            }
        }
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
}

// MARK: - Helper Method

private extension SceneDelegate {
    func updateFCMToken() {
        guard let session = userSessionRepository.fetchActiveUserSession(),
              let token = profileRepository.fetchFCMToken() else { return }
        
        profileRepository.updateUserProfile(nickname: session.nickname, fcmToken: token)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    WableLogger.log("토큰 업데이트 실패: \(error)", for: .error)
                default:
                    break
                }
            } receiveValue: { _ in
                WableLogger.log("토큰 업데이트 성공", for: .debug)
            }
            .store(in: cancelBag)
    }
    
    func checkUpdate() {
        Task {
            do {
                let requirement = try await checkAppUpdateRequirementUseCase.execute()
                
                if requirement == .none {
                    await MainActor.run { proceedToAppLaunch() }
                    return
                }
                
                await MainActor.run { showUpdateAlert(for: requirement) }
            } catch {
                WableLogger.log(error.localizedDescription, for: .error)
                await MainActor.run { proceedToAppLaunch() }
            }
        }
    }
    
    func showUpdateAlert(for requirement: UpdateRequirement) {
        let sheet = WableSheetViewController(
            title: StringLiterals.Update.title,
            message: StringLiterals.Update.message
        )
        
        if requirement == .frequent || requirement == .optional {
            let cancel = WableSheetAction(title: "취소", style: .gray) { [weak self] in self?.proceedToAppLaunch() }
            sheet.addAction(cancel)
        }
        
        let update = WableSheetAction(title: "업데이트 하기", style: .primary) { [weak self] in self?.openAppStore() }
        sheet.addAction(update)
        
        window?.rootViewController?.present(sheet, animated: true)
    }
    
    func openAppStore() {
        guard let url = URL(string: StringLiterals.URL.appStore),
              UIApplication.shared.canOpenURL(url)
        else {
            WableLogger.log("앱스토어를 열 수 없습니다.", for: .error)
            return
        }
        
        UIApplication.shared.open(url)
    }
}
