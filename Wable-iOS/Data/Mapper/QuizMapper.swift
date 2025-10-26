//
//  QuizMapper.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/25/25.
//

import Foundation

enum QuizMapper { }

extension QuizMapper {
    static func toDomain(_ response: DTO.Response.FetchQuiz) -> Quiz {
        return Quiz(
            id: response.id,
            imageURL: response.imageURL,
            text: response.text,
            answer: response.answer
        )
    }
    
    static func toDomain(_ response: DTO.Response.UpdateQuizGradeResponse) -> QuizResult {
        return QuizResult(
            isCorrect: response.answer,
            topPercent: response.topPercent,
            continueDay: response.continueDay
        )
    }
}
