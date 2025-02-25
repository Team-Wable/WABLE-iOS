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
    case updatePreRegister(request: DTO.Request.UpdatePreRegister)
    case fetchCommunityList
}

extension CommunityTargetType: BaseTargetType {
    var endPoint: String? {
        switch self {
        case .updatePreRegister:
            return "/v1/community/prein"
        case .fetchCommunityList:
            return "/v1/community/list"
        }
    }
    
    var query: [String : Any]? {
        return .none
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .updatePreRegister(request: let request):
            return request
        case .fetchCommunityList:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .updatePreRegister:
            return .post
        case .fetchCommunityList:
            return .get
        }
    }
}
