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
    private let profileRepository = ProfileRepositoryImpl()
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
        checkForceUpdate()
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
                updateFCMTokenUseCase: UpdateFCMTokenUseCase(
                    repository: ProfileRepositoryImpl()
                ),
                fetchUserAuthUseCase: FetchUserAuthUseCase(
                    loginRepository: loginRepository,
                    userSessionRepository: userSessionRepository
                ),
                updateUserSessionUseCase: FetchUserInformationUseCase(repository: userSessionRepository),
                userProfileUseCase: UserProfileUseCase(repository: ProfileRepositoryImpl())
            )
        )
    }
    
    func configureMainScreen() {
        if let id = userSessionRepository.fetchActiveUserID() {
            profileRepository.fetchUserProfile(memberID: id)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                } receiveValue: { [weak self] info in
                    guard let self = self else { return }
                    let token = self.profileRepository.fetchFCMToken()
                    
                    self.userSessionRepository.updateUserSession(
                        userID: id,
                        nickname: info.user.nickname,
                        profileURL: info.user.profileURL,
                        isAutoLoginEnabled: true
                    )
                    
                    self.profileRepository.updateUserProfile(nickname: info.user.nickname, fcmToken: token)
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
                .store(in: cancelBag)
        }
        
        self.window?.rootViewController = TabBarController(shouldShowLoadingScreen: true)
    }
    
    func proceedToAppLaunch() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) { [weak self] in
            guard let self = self,
            let session = userSessionRepository.fetchActiveUserSession(),
            let isAutoLoginEnabled = session.isAutoLoginEnabled
            else {
                return
            }
            
            (session.nickname != "" && isAutoLoginEnabled) ? configureMainScreen() : configureLoginScreen()
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
    func checkForceUpdate() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        guard let url = URL(string: StringLiterals.URL.itunes) else {
            proceedToAppLaunch()
            
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                WableLogger.log("앱스토어 버전 확인 실패: \(error.localizedDescription)", for: .error)
                DispatchQueue.main.async {
                    self.proceedToAppLaunch()
                }
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let appStoreInfo = results.first,
                  let appStoreVersion = appStoreInfo["version"] as? String,
                  let currentVersion = appVersion
            else {
                WableLogger.log("앱스토어 데이터 파싱 실패", for: .error)
                
                DispatchQueue.main.async {
                    self.proceedToAppLaunch()
                }
                
                return
            }
            
            DispatchQueue.main.async {
                WableLogger.log(
                    "currentVersion: \(currentVersion), appStoreVersion: \(appStoreVersion)",
                    for: .debug
                )
                
                let isUpdateNeeded = self.isForceUpdateNeeded(
                    currentVersion: currentVersion,
                    appStoreVersion: appStoreVersion
                )
                
                isUpdateNeeded ? self.showForceUpdateAlert() : self.proceedToAppLaunch()
            }
            
        }.resume()
    }
    
    func showForceUpdateAlert() {
        let view = WableSheetViewController(
            title: StringLiterals.Update.title,
            message: StringLiterals.Update.message
        )
        
        view.addAction(.init(title: "업데이트 하기", style: .primary, handler: {
            guard let url = URL(string: StringLiterals.URL.appStore) else {
                WableLogger.log("앱스토어 URL이 올바르지 않습니다", for: .error)
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if !success {
                        WableLogger.log("앱스토어 열기 실패", for: .error)
                    }
                }
            }
        }))
        
        self.window?.rootViewController?.present(view, animated: true)
    }
    
    func isForceUpdateNeeded(currentVersion: String, appStoreVersion: String) -> Bool {
        let currentComponents = convertVersionComponents(from: currentVersion)
        let appStoreComponents = convertVersionComponents(from: appStoreVersion)
        
        if currentComponents.major != appStoreComponents.major {
            return currentComponents.major < appStoreComponents.major
        }
        
        if currentComponents.minor != appStoreComponents.minor {
            return currentComponents.minor < appStoreComponents.minor
        }
        
        return currentComponents.patch < appStoreComponents.patch
    }
    
    func convertVersionComponents(from version: String) -> (major: Int, minor: Int, patch: Int) {
        let components = version.split(separator: ".").map { Int($0) ?? 0 }
        return (
            major: components.count > 0 ? components[0] : 0,
            minor: components.count > 1 ? components[1] : 0,
            patch: components.count > 2 ? components[2] : 0
        )
    }
}
