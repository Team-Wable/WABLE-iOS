//
//  HomeRouter.swift
//  Wable-iOS
//
//  Created by 박윤빈 on 8/22/24.
//

import Foundation

import Moya

enum HomeRouter {
    case getContent(param: Int)
    case patchFCMToken(param: UserProfileRequestDTO)
}

extension HomeRouter: BaseTargetType {
    var path: String {
        switch self {
        case .getContent:
            return StringLiterals.Endpoint.Home.getContent
        case .patchFCMToken:
            return StringLiterals.Endpoint.Home.patchUserProfile
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getContent:
            return .get
        case .patchFCMToken:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getContent(let cursor):
            return .requestParameters(parameters: ["cursor": cursor], encoding: URLEncoding.queryString)
        case .patchFCMToken(let data):

            var formData = [MultipartFormData]()
            
            // fcmToken 추가
            if let fcmTokenData = data.fcmToken?.data(using: .utf8) {
                let tokenPart = MultipartFormData(provider: .data(fcmTokenData), name: "fcmToken")
                formData.append(tokenPart)
            }
            
            // isPushAlarmAllowed 추가 (Bool을 문자열로 변환하여 전송)
            let pushAlarmData = String(describing: data.isPushAlarmAllowed).data(using: .utf8) ?? Data()
            let pushAlarmPart = MultipartFormData(provider: .data(pushAlarmData), name: "isPushAlarmAllowed")
            formData.append(pushAlarmPart)
            
            return .uploadMultipart(formData)

        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getContent:
            return APIConstants.hasTokenHeader
        case .patchFCMToken:
            return APIConstants.multipartHeader
        }
    }
}
