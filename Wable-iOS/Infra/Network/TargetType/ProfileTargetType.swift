//
//  ProfileTargetType.swift
//  Wable-iOS
//
//  Created by YOUJIM on 2/18/25.
//

import Combine
import Foundation

import Moya

enum ProfileTargetType {
    case fetchUserInfo
    case fetchUserProfile(memberID: Int)
    case updateUserProfile(request: DTO.Request.UpdateUserProfile)
}

extension ProfileTargetType: BaseTargetType {
    var multipartFormData: [Moya.MultipartFormData]? {
        return .none
    }
    
    var endPoint: String? {
        switch self {
        case .fetchUserInfo:
            return "/v1/member-data"
        case .fetchUserProfile(memberID: let memberID):
            return "/v1/viewmember/\(memberID)"
        case .updateUserProfile:
            return "/v1/user-profile2"
        }
    }
    
    var query: [String : Any]? {
        return .none
    }
    
    var requestBody: (any Encodable)? {
        switch self {
        case .updateUserProfile(request: let request):
            return request
        default:
            return .none
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchUserInfo, .fetchUserProfile:
            return .get
        case .updateUserProfile:
            return .patch
        }
    }
}
