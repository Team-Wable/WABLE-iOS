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
    private let userSessionRepository: UserSessionRepository
    private let profileRepository: ProfileRepository

    // MARK: - Initializer

    init(
        window: UIWindow,
        userSessionRepository: UserSessionRepository,
        profileRepository: ProfileRepository
    ) {
        self.window = window
        self.userSessionRepository = userSessionRepository
        self.profileRepository = profileRepository
        self.navigationController = UINavigationController()
    }

    // MARK: - Start

    func start() {
        let hasActiveSession = checkActiveSession()

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
        userSessionRepository.updateActiveUserID(nil)
        showLogin()
    }
}

// MARK: - Helper Method

private extension AppCoordinator {
    func checkActiveSession() -> Bool {
        guard let session = userSessionRepository.fetchActiveUserSession(),
              let isAutoLoginEnabled = session.isAutoLoginEnabled else {
            return false
        }

        return isAutoLoginEnabled && !session.nickname.isEmpty
    }

    func updateFCMToken() {
        guard let session = userSessionRepository.fetchActiveUserSession(),
              let token = profileRepository.fetchFCMToken() else { return }

        _ = profileRepository.updateUserProfile(nickname: session.nickname, fcmToken: token)
    }
}
