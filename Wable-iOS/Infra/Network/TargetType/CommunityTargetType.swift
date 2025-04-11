//
//  CommunityTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/23/25.
//


import Combine
import Foundation

import Moya

enum CommunityTargetType {
    case updateRegister(request: DTO.Request.UpdateRegister)
    case fetchCommunityList
    case isUserRegistered
}

extension CommunityTargetType: BaseTargetType {
    var endPoint: String? {
        switch self {
        case .updateRegister:
            return "/v2/community/prein"
        case .fetchCommunityList:
            return "/v1/community/list"
        case .isUserRegistered:
            return "/v1/community/member"
        }
    }
    
    var query: [String : Any]? {
        return .none
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .updateRegister(request: let request):
            return request
        case .fetchCommunityList:
            return .none
        case .isUserRegistered:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .updateRegister:
            return .patch
        case .fetchCommunityList:
            return .get
        case .isUserRegistered:
            return .get
        }
    }
}
