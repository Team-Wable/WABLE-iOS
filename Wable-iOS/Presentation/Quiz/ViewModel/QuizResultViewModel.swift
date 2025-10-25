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

    private let updateQuizResultSubject = PassthroughSubject<Int, Never>()
    private let errorSubject = PassthroughSubject<WableError, Never>()

    @Injected private var quizRepository: QuizRepository
}

extension QuizResultViewModel: ViewModelType {
    struct Input {
        let rewardButtonDidTap: AnyPublisher<(quizId: Int, answer: Bool, totalTime: Int), Never>
    }

    struct Output {
        let updateQuizResult: AnyPublisher<Int, Never>
        let error: AnyPublisher<WableError, Never>
    }

    func transform(input: Input, cancelBag: CancelBag) -> Output {
        input.rewardButtonDidTap
            .withUnretained(self)
            .flatMap { owner, data -> AnyPublisher<Int, Never> in
                return owner.updateQuizAnswer(
                    id: data.quizId,
                    answer: data.answer,
                    totalTime: data.totalTime
                )
            }
            .sink(receiveValue: { [weak self] xpValue in
                self?.updateQuizResultSubject.send(xpValue)
            })
            .store(in: cancelBag)

        return Output(
            updateQuizResult: updateQuizResultSubject.eraseToAnyPublisher(),
            error: errorSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - Helper Method

private extension QuizResultViewModel {
    func updateQuizAnswer(id: Int, answer: Bool, totalTime: Int) -> AnyPublisher<Int, Never> {
        return quizRepository.updateQuizAnswer(
            id: id,
            answer: answer,
            totalTime: totalTime
        )
        .catch { [weak self] error -> AnyPublisher<Int, Never> in
            self?.errorSubject.send(error)
            return Empty<Int, Never>().eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
