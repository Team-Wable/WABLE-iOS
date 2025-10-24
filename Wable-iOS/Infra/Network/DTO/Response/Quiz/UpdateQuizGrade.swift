//
//  UpdateQuizGrade.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/24/25.
//

import Foundation

extension DTO.Response {
    struct UpdateQuizGrade: Decodable {
        let answer: String
        let topPercent: Int
        let continueDay: Int
        
        enum CodingKeys: String, CodingKey {
            case answer = "quizResult"
            case topPercent = "userPercent"
            case continueDay = "continueNumber"
        }
    }
}
