//
//  FetchQuiz.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/24/25.
//

import Foundation

extension DTO.Response {
    struct FetchQuiz: Decodable {
        let id: Int
        let imageURL: String
        let text: String
        let answer: Bool
        
        enum CodingKeys: String, CodingKey {
            case id = "quizId"
            case imageURL = "quizImage"
            case text = "quizText"
            case answer = "quizAnswer"
        }
    }
}
