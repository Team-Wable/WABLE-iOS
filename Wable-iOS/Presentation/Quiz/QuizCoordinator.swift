//
//  QuizCoordinator.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/21/25.
//

import UIKit

public final class QuizCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    public var onFinish: (() -> Void)?
    private var hasCompleted: Bool
    
    init(navigationController: UINavigationController, hasCompleted: Bool) {
        self.navigationController = navigationController
        self.hasCompleted = hasCompleted
    }
    
    func start() {
        showNextQuizInfoView()
    }
}

public extension QuizCoordinator {
    func showNextQuizInfoView() {
        let viewController = NextQuizInfoViewController(type: .quiz, viewModel: .init())
        navigationController.setViewControllers([viewController], animated: false)
    }
    
//    func showResultView(isCorrect: Bool) {
//        let viewController = QuizResultViewController(
//            viewModel: QuizResultViewModel(),
//            answer: isCorrect,
//            totalTime: 0
//        )
//
//        navigationController.present(viewController, animated: true)
//    }
}
