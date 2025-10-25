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
    private let answerInfoSubject = PassthroughSubject<(answer: Bool, totalTime: Int), Never>()
    private let errorSubject = PassthroughSubject<WableError, Never>()
    private var quizStartTime: Date?
    
    @Injected private var quizRepository: QuizRepository
    @Injected private var userSessionRepository: UserSessionRepository
}

extension QuizViewModel: ViewModelType {
    struct Input {
        let submitButtonDidTap: AnyPublisher<Bool, Never>
    }
    
    struct Output {
        let quizInfo: AnyPublisher<Quiz, Never>
        let answerInfo: AnyPublisher<(answer: Bool, totalTime: Int), Never>
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
            .compactMap { [weak self] (data: (userAnswer: Bool, quiz: Quiz)) -> (answer: Bool, totalTime: Int)? in
                guard let startTime = self?.quizStartTime else { return nil }
                let totalTime = Int(Date().timeIntervalSince(startTime))

                return (answer: data.userAnswer, totalTime: totalTime)
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.updateQuizCompletedAt()
                owner.answerInfoSubject.send(result)
            })
            .store(in: cancelBag)

        return Output(
            quizInfo: quizInfoSubject.compactMap { $0 }.eraseToAnyPublisher(),
            answerInfo: answerInfoSubject.eraseToAnyPublisher(),
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
    
    func updateQuizCompletedAt() {
        guard let userSession = userSessionRepository.fetchActiveUserSession() else { return }

        userSessionRepository.updateUserSession(
            userID: userSession.id,
            nickname: userSession.nickname,
            profileURL: userSession.profileURL,
            isPushAlarmAllowed: userSession.isPushAlarmAllowed,
            isAdmin: userSession.isAdmin,
            isAutoLoginEnabled: userSession.isAutoLoginEnabled,
            notificationBadgeCount: userSession.notificationBadgeCount,
            quizCompletedAt: Date()
        )
    }
}
