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

        viewController.navigateToProfileRegister = { [weak self] year, team in
            self?.showProfileRegister(year: year, team: team)
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    func showProfileRegister(year: Int, team: String) {
        let viewController = ProfileRegisterViewController(lckYear: year, lckTeam: team)

        viewController.navigateToAgreement = { [weak self] nickname, year, team, profileImage, defaultImage in
            self?.showAgreement(
                nickname: nickname,
                year: year,
                team: team,
                profileImage: profileImage,
                defaultImage: defaultImage
            )
        }

        navigationController.pushViewController(viewController, animated: true)
    }

    func showAgreement(nickname: String, year: Int, team: String, profileImage: UIImage?, defaultImage: String?) {
        let viewController = AgreementViewController(
            nickname: nickname,
            lckTeam: team,
            lckYear: year,
            profileImage: profileImage,
            defaultImage: defaultImage
        )

        viewController.navigateToHome = { [weak self] in self?.showHome() }
        navigationController.pushViewController(viewController, animated: true)
    }

    func showHome() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        navigationController.present(tabBarController, animated: true)
    }
}
