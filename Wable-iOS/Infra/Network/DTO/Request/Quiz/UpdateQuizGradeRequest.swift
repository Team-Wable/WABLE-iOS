//
//  UpdateQuizGradeRequest.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/24/25.
//

import Foundation

extension DTO.Request {
    struct UpdateQuizGradeRequest: Encodable {
        let id: Int
        let answer: Bool
        let totalTime: Int
        
        enum CodingKeys: String, CodingKey {
            case id = "quizId"
            case answer = "userAnswer"
            case totalTime = "quizTime"
        }
    }
}
