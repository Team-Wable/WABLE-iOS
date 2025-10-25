//
//  QuizViewModel.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/25/25.
//


import Combine
import Foundation

import CombineMoya
import Moya

final class QuizViewModel {

    // MARK: Property

    private let quizInfoSubject = CurrentValueSubject<Quiz?, Never>(nil)
    private let isAnswerSubject = PassthroughSubject<(isCorrect: Bool, totalTime: Int), Never>()
    private let errorSubject = PassthroughSubject<WableError, Never>()
    private var quizStartTime: Date?

    @Injected private var quizRepository: QuizRepository
}

extension QuizViewModel: ViewModelType {
    struct Input {
        let submitButtonDidTap: AnyPublisher<Bool, Never>
    }
    
    struct Output {
        let quizInfo: AnyPublisher<Quiz, Never>
        let answerInfo: AnyPublisher<(isCorrect: Bool, totalTime: Int), Never>
        let error: AnyPublisher<WableError, Never>
    }
    
    func transform(input: Input, cancelBag: CancelBag) -> Output {
        fetchQuiz()
            .withUnretained(self)
            .sink(receiveValue: { owner, quiz in
                owner.quizInfoSubject.send(quiz)
                owner.quizStartTime = Date()
            })
            .store(in: cancelBag)
        
        input.submitButtonDidTap
            .withLatestFrom(quizInfoSubject.compactMap { $0 }) { userAnswer, quiz in
                return (userAnswer: userAnswer, quiz: quiz)
            }
            .compactMap { [weak self] userAnswer, quiz in
                guard let startTime = self?.quizStartTime else { return nil }
                let totalTime = Int(Date().timeIntervalSince(startTime))
                let isCorrect = userAnswer == quiz.answer
                return (isCorrect: isCorrect, totalTime: totalTime)
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.isAnswerSubject.send(result)
            })
            .store(in: cancelBag)

        return Output(
            quizInfo: quizInfoSubject.compactMap { $0 }.eraseToAnyPublisher(),
            answerInfo: isAnswerSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension QuizViewModel {
    func fetchQuiz() -> AnyPublisher<Quiz, Never> {
        return quizRepository.fetchQuiz()
            .catch { [weak self] error -> AnyPublisher<Quiz, Never> in
                self?.errorSubject.send(error)
                return Empty<Quiz, Never>().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
