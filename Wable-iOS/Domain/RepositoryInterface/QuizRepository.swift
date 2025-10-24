//
//  QuizRepository.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/25/25.
//

import Combine
import Foundation

protocol QuizRepository {
    func updateQuizAnswer(id: Int, answer: Bool, totalTime: Int) -> AnyPublisher<Int, WableError>
    func fetchQuiz() -> AnyPublisher<Quiz, WableError>
}
