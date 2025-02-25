//
//  AccountTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//


import Foundation

import Moya

enum AccountTargetType {
    case deleteAccount(request: DTO.Request.DeleteAccount)
    case fetchNicknameDuplication(nickname: String)
    case updateUserBadge(badge: Int)
}

extension AccountTargetType: BaseTargetType {
    var endPoint: String? {
        switch self {
        case .deleteAccount:
            return "/v1/withdrawal"
        case .fetchNicknameDuplication:
            return "/v1/nickname-validation"
        case .updateUserBadge:
            return "/v1/fcmbadge"
        }
    }
    
    var query: [String : Any]? {
        switch self {
        case .fetchNicknameDuplication(nickname: let nickname):
            return ["nickname" : nickname]
        default:
            return .none
        }
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .deleteAccount(request: let request):
            return request
        default:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .deleteAccount, .updateUserBadge:
            return .patch
        case .fetchNicknameDuplication:
            return .get
        }
    }
}
