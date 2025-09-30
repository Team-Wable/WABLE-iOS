//
//  LoginCoordinator.swift
//  Wable-iOS
//
//  Created by YOUJIM on 9/30/25.
//


import UIKit

final class LoginCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = LoginViewModel()
        let viewController = LoginViewController(viewModel: viewModel)

        viewController.navigateToOnboarding = { [weak self] in
            self?.showOnboarding()
        }

        viewController.navigateToHome = { [weak self] in
            self?.showHome()
        }

        navigationController.setViewControllers([viewController], animated: false)
    }
}

private extension LoginCoordinator {
    func showOnboarding() {
        let noticeViewController = WableSheetViewController(
            title: "앗 잠깐!",
            message: StringLiterals.Onboarding.enterSheetTitle
        )

        noticeViewController.addAction(.init(title: "확인", style: .primary, handler: { [weak self] in
            guard let self else { return }

            let navigationController = UINavigationController()
            navigationController.navigationBar.isHidden = true
            navigationController.modalPresentationStyle = .fullScreen

            let coordinator = OnboardingCoordinator(navigationController: navigationController)
            self.childCoordinators.append(coordinator)
            coordinator.start()

            self.navigationController.present(navigationController, animated: true)
        }))

        navigationController.present(noticeViewController, animated: true)
    }

    func showHome() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        navigationController.present(tabBarController, animated: true)
    }
}
