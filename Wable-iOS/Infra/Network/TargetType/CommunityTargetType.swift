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
    case isUserRegisterd
}

extension CommunityTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .updateRegister:
            return "/v2/community/prein"
        case .fetchCommunityList:
            return "/v1/community/list"
        case .isUserRegisterd:
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
        case .isUserRegisterd:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .updateRegister:
            return .patch
        case .fetchCommunityList:
            return .get
        case .isUserRegisterd:
            return .get
        }
    }
}
