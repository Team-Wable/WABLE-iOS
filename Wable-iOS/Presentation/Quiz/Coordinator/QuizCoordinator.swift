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
<<<<<<< HEAD:Wable-iOS/Presentation/Quiz/Coordinator/QuizCoordinator.swift
=======
    
<<<<<<< HEAD:Wable-iOS/Presentation/Quiz/Coordinator/QuizCoordinator.swift
    func showResultView(isCorrect: Bool) {
        let viewController = QuizResultViewController(
            viewModel: QuizResultViewModel(),
            answer: isCorrect,
            totalTime: 0
        )

        navigationController.present(viewController, animated: true)
    }
>>>>>>> fabc822 (feat: #294 - 퀴즈 화면 UI 구현 및 네비게이션 설정):Wable-iOS/Presentation/Quiz/QuizCoordinator.swift
=======
//    func showResultView(isCorrect: Bool) {
//        let viewController = QuizResultViewController(
//            viewModel: QuizResultViewModel(),
//            answer: isCorrect,
//            totalTime: 0
//        )
//
//        navigationController.present(viewController, animated: true)
//    }
>>>>>>> 4d5787a ([Chore] #294 - 불필요한 코드 정리 및 프로젝트 파일 업데이트):Wable-iOS/Presentation/Quiz/QuizCoordinator.swift
}
