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
        switch self {
        case .updateUserProfile(request: let request):
            var multipartFormData: [MultipartFormData] = []
            
            let parameters: [String: Any?] = [
                "nickname": request.info?.nickname,
                "isAlarmAllowed": request.info?.isAlarmAllowed,
                "memberIntro": request.info?.memberIntro,
                "isPushAlarmAllowed": request.info?.isPushAlarmAllowed,
                "fcmToken": request.info?.fcmToken,
                "memberLckYears": request.info?.memberLCKYears,
                "memberFanTeam": request.info?.memberFanTeam,
                "memberDefaultProfileImage": request.info?.memberDefaultProfileImage
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
                let textData = MultipartFormData(
                    provider: .data(jsonData),
                    name: "info"
                )
                
                multipartFormData.append(textData)
            }
            
            if let imageData = request.file {
                let imageFormData = MultipartFormData(
                    provider: .data(imageData),
                    name: "file",
                    fileName: "profile.jpeg",
                    mimeType: "image/jpeg"
                )
                
                multipartFormData.append(imageFormData)
            }
            
            return multipartFormData
        default:
            return .none
        }
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
        return .none
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
