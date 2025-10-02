//
//  OnboardingCoordinator.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/1/25.
//

import UIKit

final class OnboardingCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showLCKYear()
    }
}

// MARK: - Navigation Methods

private extension OnboardingCoordinator {
    func showLCKYear() {
        let viewController = LCKYearViewController(type: .flow)

        viewController.navigateToLCKTeam = { [weak self] year in
            self?.showLCKTeam(year: year)
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    func showLCKTeam(year: Int) {
        let viewController = LCKTeamViewController(lckYear: year)

        viewController.navigateToProfileRegister = { [weak self] profileInfo in
            self?.showProfileRegister(profileInfo: profileInfo)
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    func showProfileRegister(profileInfo: OnboardingProfileInfo) {
        let viewController = ProfileRegisterViewController(profileInfo: profileInfo)

        viewController.navigateToAgreement = { [weak self] profileInfo in
            self?.showAgreement(profileInfo: profileInfo)
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    func showAgreement(profileInfo: OnboardingProfileInfo) {
        let viewController = AgreementViewController(profileInfo: profileInfo)

        viewController.navigateToHome = { [weak self] in self?.showHome() }
        navigationController.pushViewController(viewController, animated: true)
    }

    func showHome() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            return WableLogger.log("SceneDelegate 찾을 수 없음.", for: .debug)
        }

        let tabBarController = TabBarController()

        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionCrossDissolve],
            animations: { window.rootViewController = tabBarController },
            completion: { [weak self] _ in
                self?.onFinish?()
            }
        )
    }
}
