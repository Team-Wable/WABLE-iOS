//
//  QuizRepositoryImpl.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/25/25.
//

import Combine
import Foundation

import CombineMoya
import Moya

final class QuizRepositoryImpl {
    private let provider: APIProvider<QuizTargetType>
    
    init(provider: APIProvider<QuizTargetType> = .init()) {
        self.provider = provider
    }
}

extension QuizRepositoryImpl: QuizRepository {
    func updateQuizAnswer(id: Int, answer: Bool, totalTime: Int) -> AnyPublisher<Int, WableError> {
        let request = DTO.Request.UpdateQuizGradeRequest(
            id: id,
            answer: answer,
            totalTime: totalTime
        )

        return provider.request(.updateQuizGrade(request: request), for: DTO.Response.UpdateQuizGradeResponse.self)
            .compactMap { response in
                response.topPercent
            }
            .mapWableError()
    }
    
    func fetchQuiz() -> AnyPublisher<Quiz, WableError> {
        return provider.request(.fetchQuiz, for: DTO.Response.FetchQuiz.self)
            .map(QuizMapper.toDomain)
            .mapWableError()
    }
}

struct MockQuizRepository: QuizRepository {
    private var randomDelay: TimeInterval { Double.random(in: 0.7...1.3) }
    
    func updateQuizAnswer(id: Int, answer: Bool, totalTime: Int) -> AnyPublisher<Int, WableError> {
        return .just(Int.random(in: 1...99))
            .delay(for: .seconds(randomDelay), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchQuiz() -> AnyPublisher<Quiz, WableError> {
        return .just(
            Quiz(
                id: Int.random(in: 1...9999),
                imageURL: "https://i.namu.wiki/i/fCEPJxFsbeApqrKcOytGSfHscsihhok9e7Dk_-I628_I0vdWaFyWOMEqor_2BGm1DgJPg8zHfrcbu31FBMPj3A.webp",
                text: "이 룬은 칼날비라는 룬으로 적에게 기본 공격을 3번 가하면 일정 시간 동안 공격 속도가 크게 증가하는 룬이다.",
                answer: true
            )
        )
        .delay(for: .seconds(randomDelay), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
