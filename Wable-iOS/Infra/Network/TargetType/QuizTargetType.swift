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
<<<<<<< HEAD
    case updateQuizGrade(request: DTO.Request.UpdateQuizGradeRequest)
=======
    case updateQuizGrade(request: DTO.Request.UpdateQuizGrade)
>>>>>>> c4ce0ce ([Add] #294 - 퀴즈 API 관련 DTO 및 TargetType 파일 추가)
}

extension QuizTargetType: BaseTargetType {
    var endPoint: String? {
        switch self {
        case .fetchQuiz:
            "/v1/quiz"
<<<<<<< HEAD
        case .updateQuizGrade:
=======
        case .updateQuizGrade(request: let request):
>>>>>>> c4ce0ce ([Add] #294 - 퀴즈 API 관련 DTO 및 TargetType 파일 추가)
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
<<<<<<< HEAD
            return .get
        case .updateQuizGrade:
            return .patch
=======
            return .patch
        case .updateQuizGrade:
            return .get
>>>>>>> c4ce0ce ([Add] #294 - 퀴즈 API 관련 DTO 및 TargetType 파일 추가)
        }
    }
}

