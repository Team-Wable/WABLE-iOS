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
<<<<<<< HEAD:Wable-iOS/Presentation/Quiz/Coordinator/QuizCoordinator.swift
        let viewController = NextQuizInfoViewController(type: .quiz, viewModel: .init())
        navigationController.setViewControllers([viewController], animated: false)
=======
        let viewController = NextQuizInfoViewController()
        navigationController.setViewControllers([viewController], animated: false)
    }
    
<<<<<<< HEAD:Wable-iOS/Presentation/Quiz/Coordinator/QuizCoordinator.swift
    func showResultView(isCorrect: Bool) {
        let viewController = QuizResultViewController(
            viewModel: QuizResultViewModel(),
            answer: isCorrect,
            totalTime: 0
        )

        navigationController.present(viewController, animated: true)
>>>>>>> 906e044 ([Fix] #294 - 퀴즈 탭 선택 시 현재 화면에서 push되도록 네비게이션 로직 수정):Wable-iOS/Presentation/Quiz/QuizCoordinator.swift
    }
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
>>>>>>> f9a97e0 ([Chore] #294 - 불필요한 코드 정리 및 프로젝트 파일 업데이트):Wable-iOS/Presentation/Quiz/QuizCoordinator.swift
}
