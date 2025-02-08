//
//  LoginRouter.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 2/6/25.
//

import Foundation

import Moya

enum LoginRouter {
    case postSocialLogin(requestBody: SocialLoginRequestDTO, accessToken: String)
}

extension LoginRouter: BaseTargetType {
    var path: String {
        switch self {
        case .postSocialLogin:
            return StringLiterals.Endpoint.Login.postSocialLogin

        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postSocialLogin:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postSocialLogin(let requestBody, _):
            return .requestJSONEncodable(requestBody)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postSocialLogin(_, let accessToken):
            print("accessToken: \(accessToken)💖💖")
            return APIConstants.loginHeader(accessToken: accessToken)
        }
    }
    
}
