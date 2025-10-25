//
//  UpdateQuizGradeResponse.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/24/25.
//

import Foundation

extension DTO.Response {
    struct UpdateQuizGradeResponse: Decodable {
<<<<<<< HEAD
        let answer: Bool
=======
        let answer: String
>>>>>>> fabc822 (feat: #294 - 퀴즈 화면 UI 구현 및 네비게이션 설정)
        let topPercent: Int
        let continueDay: Int
        
        enum CodingKeys: String, CodingKey {
            case answer = "quizResult"
            case topPercent = "userPercent"
            case continueDay = "continueNumber"
        }
    }
}
