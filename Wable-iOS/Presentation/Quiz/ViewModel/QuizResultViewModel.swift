//
//  QuizResultViewModel.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/22/25.
//


import Combine
import Foundation

final class QuizResultViewModel {

    // MARK: Property

    private let quizInfo: (id: Int, userAnswer: Bool, totalTime: Int)
    private let updateQuizResultSubject = PassthroughSubject<(result: QuizResult, speed: Int), Never>()
    private let errorSubject = PassthroughSubject<WableError, Never>()

    @Injected private var quizRepository: QuizRepository
    @Injected private var userSessionRepository: UserSessionRepository
    
    // MARK: - Life Cycle
    
    init(quizInfo: (id: Int, userAnswer: Bool, totalTime: Int)) {
        self.quizInfo = quizInfo
    }
}

extension QuizResultViewModel: ViewModelType {
    struct Input { }

    struct Output {
        let updateQuizResult: AnyPublisher<(result: QuizResult, speed: Int), Never>
        let error: AnyPublisher<WableError, Never>
    }

    func transform(input: Input, cancelBag: CancelBag) -> Output {
        updateQuizAnswer()
            .withUnretained(self)
            .map { owner, quizResult in
                return (result: quizResult, speed: owner.quizInfo.totalTime)
            }
            .sink { [weak self] result in
                self?.updateQuizResultSubject.send(result)
            }
            .store(in: cancelBag)

        return Output(
            updateQuizResult: updateQuizResultSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension QuizResultViewModel {
    func updateQuizAnswer() -> AnyPublisher<QuizResult, Never> {
        return quizRepository.updateQuizAnswer(
            id: quizInfo.id,
            answer: quizInfo.userAnswer,
            totalTime: quizInfo.totalTime
        )
        .catch { [weak self] error -> AnyPublisher<QuizResult, Never> in
            self?.errorSubject.send(error)
            return Empty<QuizResult, Never>().eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
