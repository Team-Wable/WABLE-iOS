//
//  QuizTargetType.swift
//  Wable-iOS
//
//  Created by Youjin Lee on 10/24/25.
//

import Combine
import Foundation

import Moya

enum QuizTargetType {
    case fetchQuiz
    case updateQuizGrade(request: DTO.Request.UpdateQuizGradeRequest)
}

extension QuizTargetType: BaseTargetType {
    var endPoint: String? {
        switch self {
        case .fetchQuiz:
            "/v1/quiz"
        case .updateQuizGrade:
            "/v1/quiz/grade"
        }
    }
    
    var query: [String : Any]? {
        return .none
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .fetchQuiz:
            return .none
        case .updateQuizGrade(request: let request):
            return request
        }
    }
    
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchQuiz:
            return .get
        case .updateQuizGrade:
            return .patch
        }
    }
}

