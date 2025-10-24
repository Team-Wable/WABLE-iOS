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
        let request = DTO.Request.UpdateQuizGrade(
            id: id,
            answer: answer,
            totalTime: totalTime
        )
        
        return provider.request(.updateQuizGrade(request: request), for: DTO.Response.UpdateQuizGrade.self)
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
