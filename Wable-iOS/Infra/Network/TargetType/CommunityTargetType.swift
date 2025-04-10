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
    case isUserPreRegisterd
}

extension CommunityTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .updatePreRegister:
            return "/v2/community/prein"
        case .fetchCommunityList:
            return "/v1/community/list"
        case .isUserPreRegisterd:
            return "/v1/community/member"
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
        case .isUserPreRegisterd:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .updatePreRegister:
            return .patch
        case .fetchCommunityList:
            return .get
        case .isUserPreRegisterd:
            return .get
        }
    }
}
