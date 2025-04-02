//
//  LoginTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Combine
import Foundation

import Moya

enum LoginTargetType {
    case fetchTokenStatus
    case fetchUserAuth(request: DTO.Request.CreateAccount)
}

extension LoginTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var query: [String : Any]? {
        return .none
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .fetchUserAuth(request: let request):
            return request
        default:
            return .none
        }
    }
    
    var endPoint: String? {
        switch self {
        case .fetchTokenStatus:
            return "/v1/auth/token"
        case .fetchUserAuth:
            return "/v2/auth"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchTokenStatus:
            return .get
        case .fetchUserAuth:
            return .post
        }
    }
}
