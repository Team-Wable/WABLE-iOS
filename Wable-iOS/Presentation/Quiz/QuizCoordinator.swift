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
    
    init(navigationController: UINavigationController,
         hasCompleted: Bool
    ) {
        self.navigationController = navigationController
        self.hasCompleted = hasCompleted
    }
    
    func start() {
        hasCompleted ? showQuizView() : showNextQuizInfoView()
    }
}

public extension QuizCoordinator {
    func showQuizView() {
        let viewController = QuizViewController()
        
        navigationController.present(viewController, animated: true)
    }
    
    func showNextQuizInfoView() {
        let viewController = NextQuizInfoViewController()
        
        navigationController.present(viewController, animated: true)
    }
}
