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
    private let checkAppUpdateRequirementUseCase = CheckAppUpdateRequirementUseCaseImpl()
    
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
            guard let self = self else { return }
            
            userSessionRepository.checkAutoLogin()
                .withUnretained(self)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        WableLogger.log("자동 로그인 여부 체크 실패: \(error)", for: .error)
                        self.configureLoginScreen()
                    }
                } receiveValue: { owner, isAutologinEnabled in
                    WableLogger.log("자동 로그인 여부 체크 성공: \(isAutologinEnabled)", for: .debug)
                    isAutologinEnabled ? owner.configureMainScreen() : owner.configureLoginScreen()
                }
                .store(in: cancelBag)
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
