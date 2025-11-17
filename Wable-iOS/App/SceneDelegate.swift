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

    private let checkAppUpdateRequirementUseCase = CheckAppUpdateRequirementUseCaseImpl()
    private let cancelBag = CancelBag()

    @Injected private var userSessionRepository: UserSessionRepository
    @Injected private var profileRepository: ProfileRepository

    private var appCoordinator: AppCoordinator?

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
    func proceedToAppLaunch() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) { [weak self] in
            guard let self = self, let window = self.window else { return }
            
            let hasActiveSession = checkActiveSession()

            self.appCoordinator = AppCoordinator(window: window)
            self.appCoordinator?.start(hasActiveSession: hasActiveSession)
        }
    }
}

// MARK: - Setup

private extension SceneDelegate {
    func setupBinding() {
        OAuthEventManager.shared.tokenExpiredSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.appCoordinator?.handleTokenExpired()
            }
            .store(in: cancelBag)
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
                await MainActor.run { proceedToAppLaunch() }
            }
        }
    }
    
    func checkActiveSession() -> Bool {
        guard let session = userSessionRepository.fetchActiveUserSession(),
              let isAutoLoginEnabled = session.isAutoLoginEnabled else {
            return false
        }

        return isAutoLoginEnabled && !session.nickname.isEmpty
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
