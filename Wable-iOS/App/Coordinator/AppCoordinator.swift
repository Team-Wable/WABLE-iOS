//
//  AppCoordinator.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/16/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    // MARK: - Property

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?

    private let window: UIWindow

    @Injected private var userSessionRepository: UserSessionRepository
    @Injected private var profileRepository: ProfileRepository

    // MARK: - Initializer

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    // MARK: - Start
    
    func start() { }

    func start(hasActiveSession: Bool) {
        if hasActiveSession {
            updateFCMToken()
            showMain()
        } else {
            showLogin()
        }
    }

    // MARK: - Navigation

    func showLogin() {
        childCoordinators.removeAll()

        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true

        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.onFinish = { [weak self] in
            self?.childDidFinish(loginCoordinator)
            self?.showMain()
        }

        childCoordinators.append(loginCoordinator)
        loginCoordinator.start()

        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionCrossDissolve],
            animations: {
                self.window.rootViewController = navigationController
            },
            completion: nil
        )
    }

    func showMain() {
        if let loginCoordinator = childCoordinators.first(where: { $0 is LoginCoordinator }) {
            childDidFinish(loginCoordinator)
        }

        let mainCoordinator = MainCoordinator(window: window)
        mainCoordinator.onLogout = { [weak self] in
            self?.handleLogout()
        }
        mainCoordinator.start()

        childCoordinators.append(mainCoordinator)
    }

    // MARK: - Helper

    private func handleLogout() {
        HomeViewController.hasShownLoadingScreen = false
        showLogin()
    }

    func handleTokenExpired() {
        HomeViewController.hasShownLoadingScreen = false
        showLogin()

        let toast = ToastView(status: .caution, message: "세션이 만료되었습니다. 다시 로그인해주세요.")
        toast.show()
    }
}

// MARK: - Helper Method

private extension AppCoordinator {
    func updateFCMToken() {
        guard let session = userSessionRepository.fetchActiveUserSession(),
              let token = profileRepository.fetchFCMToken() else { return }

        _ = profileRepository.updateUserProfile(nickname: session.nickname, fcmToken: token)
    }
}
