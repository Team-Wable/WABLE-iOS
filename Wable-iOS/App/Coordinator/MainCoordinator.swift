//
//  MainCoordinator.swift
//  Wable-iOS
//
//  Created by YOUJIM on 10/16/25.
//

import UIKit

final class MainCoordinator: Coordinator {

    // MARK: - Property

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?
    var onLogout: (() -> Void)?

    private let window: UIWindow

    // MARK: - Initializer

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    // MARK: - Start

    func start() {
        let tabBarController = TabBarController(shouldShowLoadingScreen: true)

        tabBarController.onLogout = { [weak self] in
            self?.onLogout?()
        }

        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                self.window.rootViewController = tabBarController
            }
        )
    }
}
